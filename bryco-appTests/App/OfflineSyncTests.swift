import Foundation
import Testing
@testable import bryco_app

/// A cloud backup that answers with a fixed result and records every write.
private final class FakeCloudStore: UserCloudStore {
    var loadResult: CloudLoadResult
    private(set) var savedSnapshots: [FirestoreUserSnapshot] = []

    init(loadResult: CloudLoadResult) {
        self.loadResult = loadResult
    }

    func loadUserData(uid: String) async -> CloudLoadResult { loadResult }
    func saveUserData(uid: String, snapshot: FirestoreUserSnapshot) async { savedSnapshots.append(snapshot) }
    func saveLessonProgress(uid: String, lessonId: String, mistakes: Int) async {}
}

/// Covers how local progress and the cloud backup are reconciled, especially without internet.
@MainActor
@Suite("Offline sync")
struct OfflineSyncTests {

    private func makeState(cloud: FakeCloudStore) -> BryqoAppState {
        BryqoAppState(inMemory: true, cloudStore: cloud)
    }

    @Test("Reinstall opened offline: empty local progress is never pushed over the backup")
    func unavailableCloudWritesNothing() async {
        let cloud = FakeCloudStore(loadResult: .unavailable)
        let state = makeState(cloud: cloud)   // fresh install: 0 XP, no lessons

        await state.sync(uid: "user")

        #expect(cloud.savedSnapshots.isEmpty)
        #expect(state.progress.xp == 0)
    }

    @Test("A backup the server confirms is missing is created from local progress")
    func notFoundCreatesBackup() async {
        let cloud = FakeCloudStore(loadResult: .notFound)
        let state = makeState(cloud: cloud)
        state.progress.xp = 40

        await state.sync(uid: "user")

        #expect(cloud.savedSnapshots.count == 1)
        #expect(cloud.savedSnapshots.first?.xp == 40)
    }

    @Test("An existing backup is merged into local progress, never replaced by it")
    func foundBackupIsMerged() async {
        var remote = FirestoreUserSnapshot()
        remote.xp = 900
        remote.completedLessonIds = ["logica-instrucoes", "logica-decisoes"]
        let cloud = FakeCloudStore(loadResult: .found(remote))
        let state = makeState(cloud: cloud)

        await state.sync(uid: "user")

        #expect(state.progress.xp == 900)
        #expect(state.progress.completedLessonIds.isSuperset(of: ["logica-instrucoes", "logica-decisoes"]))
        #expect(cloud.savedSnapshots.allSatisfy { $0.xp == 900 })
    }

    @Test("When the connection returns, the next sync restores the backup")
    func syncRecoversAfterGoingOnline() async {
        var remote = FirestoreUserSnapshot()
        remote.xp = 900
        let cloud = FakeCloudStore(loadResult: .unavailable)
        let state = makeState(cloud: cloud)

        await state.sync(uid: "user")      // offline launch
        cloud.loadResult = .found(remote)  // back online, app returns to foreground
        await state.sync(uid: "user")

        #expect(state.progress.xp == 900)
        #expect(cloud.savedSnapshots.allSatisfy { $0.xp == 900 })
    }
}

/// Same scenarios, with a signed-in user, so every cloud write path is exercised.
@MainActor
@Suite("Offline sync · signed in")
struct SignedInOfflineSyncTests {

    private final class Cloud: UserCloudStore {
        var loadResult: CloudLoadResult
        private(set) var saved: [FirestoreUserSnapshot] = []
        init(_ result: CloudLoadResult) { loadResult = result }
        func loadUserData(uid: String) async -> CloudLoadResult { loadResult }
        func saveUserData(uid: String, snapshot: FirestoreUserSnapshot) async { saved.append(snapshot) }
        func saveLessonProgress(uid: String, lessonId: String, mistakes: Int) async {}
    }

    private func makeState(_ cloud: Cloud) -> BryqoAppState {
        BryqoAppState(inMemory: true, cloudStore: cloud, signedInUID: { "user" })
    }

    @Test("Progress made offline stays local until the cloud has been reconciled")
    func offlineSessionNeverPushes() async throws {
        let cloud = Cloud(.unavailable)
        let state = makeState(cloud)
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        await state.syncWithCloudForTesting()
        state.completeOnboarding(displayName: "Ana", experience: "x", goal: "y", dailyGoalMinutes: 20)
        state.completeLesson(lesson)
        await Task.yield()

        #expect(cloud.saved.isEmpty)
        #expect(state.isLessonCompleted(lesson))
    }

    @Test("Once reconciled, the merged progress is pushed and later saves follow")
    func reconnectPushesMergedProgress() async throws {
        var remote = FirestoreUserSnapshot()
        remote.xp = 900
        let cloud = Cloud(.unavailable)
        let state = makeState(cloud)
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        await state.syncWithCloudForTesting()          // offline
        state.completeLesson(lesson)                   // local only
        cloud.loadResult = .found(remote)
        await state.syncWithCloudForTesting()          // back online
        for _ in 0..<5 { await Task.yield() }

        #expect(!cloud.saved.isEmpty)
        #expect(cloud.saved.allSatisfy { $0.xp >= 900 })
        #expect(cloud.saved.last?.completedLessonIds.contains(lesson.id) == true)
    }
}
