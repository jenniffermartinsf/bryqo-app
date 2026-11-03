import Foundation
import Testing
@testable import bryco_app

/// What comes back from the cloud, and what the learner types, stays inside what the app and
/// the cloud rules (firestore.rules) accept.
@MainActor
@Suite("Cloud input")
struct CloudInputTests {
    let state = BryqoAppState(inMemory: true)

    @Test("Hearts from the cloud stay between zero and the maximum", arguments: [
        (-3, 0), (0, 0), (3, 3), (5, 5), (999, 5),   // 5 is BryqoAppState.heartsMax
    ])
    func heartsClamped(remote: Int, expected: Int) {
        var snapshot = FirestoreUserSnapshot()
        snapshot.hearts = remote
        snapshot.heartsUpdatedAt = Date()

        state.mergeRemote(snapshot)

        #expect(state.progress.hearts == expected)
    }

    @Test("A long name is kept to the length the cloud rules accept")
    func longNameIsCut() {
        let longName = String(repeating: "a", count: 200)

        state.completeOnboarding(displayName: longName, experience: "Iniciante", goal: "Construir uma base", dailyGoalMinutes: 10)

        #expect(state.profile?.displayName.count == BryqoAppState.maxDisplayNameLength)
    }

    @Test("A name of emoji is cut by Unicode scalars, which is what the cloud rules count")
    func emojiNameFitsTheRules() {
        let family = "👨‍👩‍👧‍👦"   // one character, seven scalars
        let name = BryqoAppState.limitedName(String(repeating: family, count: 40))

        #expect(name.unicodeScalars.count <= BryqoAppState.maxDisplayNameLength)
        #expect(name.count == BryqoAppState.maxDisplayNameLength / family.unicodeScalars.count)
    }

    @Test("Spaces around the name are trimmed, and a blank name falls back", arguments: [
        ("  Jenni  ", "Jenni"), ("   ", "construtor"),
    ])
    func nameTrimmed(typed: String, expected: String) {
        state.completeOnboarding(displayName: typed, experience: "Iniciante", goal: "Construir uma base", dailyGoalMinutes: 10)

        #expect(state.profile?.displayName == expected)
    }
}
