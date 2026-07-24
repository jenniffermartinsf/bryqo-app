import Foundation
import Testing
@testable import bryco_app

/// Covers the level / XP / streak values surfaced on the Profile screen. All of them are
/// computed properties on `BryqoAppState`, so they're tested directly against the state the
/// view renders.
@Suite("Profile stats", .tags(.gamification))
struct ProfileStatsTests {

    private func makeState() -> BryqoAppState { BryqoAppState(inMemory: true) }

    private func daysAgo(_ n: Int) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -n, to: today)!
    }

    @Test("Level name follows the XP tier", arguments: [
        (0, "Aprendiz"),
        (100, "Estudante"),
        (250, "Desenvolvedor"),
        (500, "Arquiteto"),
        (1000, "Engenheiro"),
        (5000, "Engenheiro")
    ])
    func levelName(xp: Int, name: String) {
        let state = makeState()
        state.progress.xp = xp

        #expect(state.levelName == name)
    }

    @Test("Current-level and next-level thresholds bracket the XP")
    func levelThresholdsBracketXp() {
        let state = makeState()
        state.progress.xp = 300 // between 250 (level 3) and 500 (level 4)

        #expect(state.currentLevel == 3)
        #expect(state.xpForCurrentLevel == 250)
        #expect(state.xpForNextLevel == 500)
    }

    @Test("At the top level the next threshold clamps and progress is full")
    func topLevelClampsProgress() {
        let state = makeState()
        state.progress.xp = 12_000 // past the final 10_000 threshold

        #expect(state.xpForNextLevel == 10_000)
        #expect(state.xpProgressInLevel == 1.0)
    }

    @Test("Completed-lesson count reflects the progress set")
    func completedLessonCount() {
        let state = makeState()
        state.progress.completedLessonIds = ["a", "b", "c"]

        #expect(state.completedLessonCount == 3)
    }

    @Test("Streak is at risk when the last activity was not today")
    func streakAtRiskWhenNotStudiedToday() {
        let state = makeState()
        state.progress.streakDays = 4
        state.progress.lastActivityDate = daysAgo(1)

        #expect(state.isStreakAtRisk)
    }

    @Test("Streak is safe once studied today")
    func streakSafeWhenStudiedToday() {
        let state = makeState()
        state.progress.streakDays = 4
        state.progress.lastActivityDate = Date()

        #expect(state.isStreakAtRisk == false)
    }

    @Test("A zero-day streak is never at risk")
    func zeroStreakNotAtRisk() {
        let state = makeState()
        state.progress.streakDays = 0
        state.progress.lastActivityDate = daysAgo(3)

        #expect(state.isStreakAtRisk == false)
    }
}
