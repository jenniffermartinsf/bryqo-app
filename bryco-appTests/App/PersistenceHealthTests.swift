import Foundation
import SwiftData
import Testing
@testable import bryco_app

/// Covers how BryqoAppState reacts when the local store cannot be used.
@MainActor
@Suite("Persistence health")
struct PersistenceHealthTests {

    private struct StoreUnavailable: Error {}

    @Test("A store that opens normally reports healthy and nothing to the error log")
    func healthyStore() {
        var reported: [String] = []
        let state = BryqoAppState(inMemory: true, reportPersistenceError: { _, operation in reported.append(operation) })

        #expect(state.persistenceHealth == .healthy)
        #expect(reported.isEmpty)
    }

    @Test("A store that fails to open falls back to memory, reports it and warns the user")
    func storeFailsToOpen() {
        var reported: [String] = []
        let state = BryqoAppState(
            openStore: { throw StoreUnavailable() },
            reportPersistenceError: { _, operation in reported.append(operation) }
        )

        #expect(state.persistenceHealth == .temporaryStorage)
        #expect(reported == ["open_store"])
        #expect(state.persistenceHealth.bannerMessage != nil)
    }

    @Test("The app keeps working on the temporary store")
    func appStillWorksOnTemporaryStore() {
        let state = BryqoAppState(openStore: { throw StoreUnavailable() }, reportPersistenceError: { _, _ in })
        let lesson = BryqoContent.sampleUnit.lessons[0]

        state.completeLesson(lesson)

        #expect(state.isLessonCompleted(lesson))
        #expect(state.persistenceHealth == .temporaryStorage)
    }

    @Test("Only problems produce a banner message", arguments: [
        (PersistenceHealth.healthy, false),
        (.temporaryStorage, true),
        (.saveFailed, true)
    ])
    func bannerMessage(health: PersistenceHealth, hasMessage: Bool) {
        #expect((health.bannerMessage != nil) == hasMessage)
    }
}
