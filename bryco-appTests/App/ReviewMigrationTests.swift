import BryqoDomain
import Foundation
import SwiftData
import Testing
@testable import bryco_app

/// Opens a real V5 store on disk, then reopens it with the current migration plan, to prove that
/// people updating the app keep their spaced-repetition schedule.
@MainActor
@Suite("Review migration V5 → V6")
struct ReviewMigrationTests {

    private func makeStoreURL() throws -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("bryqo-migration-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("default.store")
    }

    /// Writes a V5 store whose user carries `states` as the old JSON blob.
    private func writeV5Store(at url: URL, states: [ReviewState], xp: Int = 0) throws {
        let schema = Schema(versionedSchema: BryqoSchemaV5.self)
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url))
        let context = ModelContext(container)
        let user = BryqoSchemaV5.PersistedUserState()
        user.xp = xp
        user.reviewStatesData = try JSONEncoder().encode(states)
        context.insert(user)
        try context.save()
    }

    private func openMigrated(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: BryqoSchemaV6.self)
        return try ModelContainer(
            for: schema,
            migrationPlan: BryqoMigrationPlan.self,
            configurations: ModelConfiguration(schema: schema, url: url)
        )
    }

    @Test("Each review in the old JSON becomes its own row, with every field kept")
    func migratesReviewsIntoRows() throws {
        let url = try makeStoreURL()
        let due = Date(timeIntervalSince1970: 1_700_000_000)
        let states = [
            ReviewState(lessonId: "a", repetitions: 2, easeFactor: 2.6, intervalDays: 6,
                        lastReviewedAt: due.addingTimeInterval(-86_400 * 6), nextReviewAt: due),
            ReviewState(lessonId: "b", repetitions: 1, easeFactor: 2.36, intervalDays: 1,
                        lastReviewedAt: due, nextReviewAt: due.addingTimeInterval(86_400))
        ]
        try writeV5Store(at: url, states: states, xp: 120)

        let container = try openMigrated(at: url)
        let context = container.mainContext

        let rows = try context.fetch(FetchDescriptor<LessonReview>(sortBy: [SortDescriptor(\.lessonId)]))
        #expect(rows.map(\.reviewState) == states)

        let user = try #require(try context.fetch(FetchDescriptor<PersistedUserState>()).first)
        #expect(user.xp == 120)
    }

    @Test("A user without reviews migrates with no rows")
    func migratesEmptyBlob() throws {
        let url = try makeStoreURL()
        try writeV5Store(at: url, states: [])

        let container = try openMigrated(at: url)

        #expect(try container.mainContext.fetchCount(FetchDescriptor<LessonReview>()) == 0)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<PersistedUserState>()) == 1)
    }
}
