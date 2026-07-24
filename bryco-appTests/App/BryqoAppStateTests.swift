import Foundation
import Testing
@testable import bryco_app

/// Exercises the gamification rules that live on `BryqoAppState`.
///
/// Each case builds a fresh `BryqoAppState(inMemory: true)`, so the SwiftData store is a
/// throwaway per test and cases never bleed into each other. No user is signed in during
/// tests, so `currentUID` stays nil and no Firestore writes are triggered.
@Suite("BryqoAppState gamification", .tags(.gamification))
struct BryqoAppStateTests {

    private func makeState() -> BryqoAppState { BryqoAppState(inMemory: true) }

    private func daysAgo(_ n: Int) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -n, to: today)!
    }

    // MARK: - Completing a lesson

    @Test("Completing a lesson awards its XP and material exactly once")
    func completingLessonAwardsOnce() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson)
        state.completeLesson(lesson) // repeat should be ignored

        #expect(state.progress.completedLessonIds == [lesson.id])
        #expect(state.progress.xp == lesson.xpReward)
        #expect(state.progress.earnedMaterials == [lesson.materialReward])
    }

    @Test("A flawless lesson refunds a heart and counts as perfect")
    func perfectLessonGainsHeart() throws {
        let state = makeState()
        state.progress.hearts = 3
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 0)

        #expect(state.progress.hearts == 4)
        #expect(state.progress.perfectLessonCount == 1)
    }

    @Test("A flawless lesson at full hearts stays capped")
    func perfectLessonCapsHearts() throws {
        let state = makeState()
        state.progress.hearts = BryqoAppState.heartsMax
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 0)

        #expect(state.progress.hearts == BryqoAppState.heartsMax)
    }

    @Test("A lesson finished with mistakes loses a heart and is not perfect")
    func lessonWithMistakesLosesHeart() throws {
        let state = makeState()
        state.progress.hearts = 3
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 2)

        #expect(state.progress.hearts == 2)
        #expect(state.progress.perfectLessonCount == 0)
    }

    // MARK: - Streak

    @Test("The first ever lesson starts the streak at one")
    func firstLessonStartsStreak() throws {
        let state = makeState()
        state.progress.lastActivityDate = nil
        state.progress.streakDays = 0
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson)

        #expect(state.progress.streakDays == 1)
    }

    @Test("Studying on a consecutive day extends the streak")
    func consecutiveDayExtendsStreak() throws {
        let state = makeState()
        state.progress.streakDays = 3
        state.progress.lastActivityDate = daysAgo(1)
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson)

        #expect(state.progress.streakDays == 4)
    }

    @Test("A second lesson on the same day does not change the streak")
    func sameDayDoesNotChangeStreak() throws {
        let state = makeState()
        state.progress.streakDays = 2
        state.progress.lastActivityDate = Date()
        let lessons = BryqoContent.logicaUnit.lessons
        try #require(lessons.count >= 2)

        state.completeLesson(lessons[1]) // a different, not-yet-completed lesson

        #expect(state.progress.streakDays == 2)
    }

    @Test("A missed day is covered by a streak freeze instead of resetting")
    func missedDayConsumesFreeze() throws {
        let state = makeState()
        state.progress.streakDays = 5
        state.progress.streakFreezeCount = 1
        state.progress.lastActivityDate = daysAgo(3)
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson)

        #expect(state.progress.streakFreezeCount == 0, "The freeze must be spent")
        #expect(state.progress.streakDays == 5, "The freeze protects the streak")
    }

    @Test("A missed day with no freeze resets the streak to one")
    func missedDayWithoutFreezeResets() throws {
        let state = makeState()
        state.progress.streakDays = 5
        state.progress.streakFreezeCount = 0
        state.progress.lastActivityDate = daysAgo(3)
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson)

        #expect(state.progress.streakDays == 1)
    }

    // MARK: - Streak decay (runs on launch / foreground, without finishing a lesson)

    @Test("Decay spends a freeze when a day was missed")
    func decaySpendsFreeze() {
        let state = makeState()
        state.progress.streakDays = 4
        state.progress.streakFreezeCount = 1
        state.progress.lastActivityDate = daysAgo(2)

        state.applyStreakDecay()

        #expect(state.progress.streakFreezeCount == 0)
        #expect(state.progress.streakDays == 4)
        #expect(Calendar.current.isDate(state.progress.lastActivityDate!, inSameDayAs: daysAgo(1)))
    }

    @Test("Decay resets the streak when there is no freeze")
    func decayResetsWithoutFreeze() {
        let state = makeState()
        state.progress.streakDays = 4
        state.progress.streakFreezeCount = 0
        state.progress.lastActivityDate = daysAgo(2)

        state.applyStreakDecay()

        #expect(state.progress.streakDays == 0)
    }

    @Test("Decay leaves the streak alone when yesterday was active")
    func decayNoopWhenActiveYesterday() {
        let state = makeState()
        state.progress.streakDays = 4
        state.progress.lastActivityDate = daysAgo(1)

        state.applyStreakDecay()

        #expect(state.progress.streakDays == 4)
    }

    // MARK: - Hearts regeneration

    @Test("Hearts regenerate one per interval elapsed")
    func heartsRegenerateOverTime() {
        let state = makeState()
        state.progress.hearts = 2
        // Two full regen intervals plus a bit.
        state.progress.heartsUpdatedAt = Date().addingTimeInterval(-(2 * BryqoAppState.heartRegenInterval + 60))

        state.applyHeartRegeneration()

        #expect(state.progress.hearts == 4)
    }

    @Test("Heart regeneration never exceeds the maximum")
    func heartsRegenerationCaps() {
        let state = makeState()
        state.progress.hearts = 4
        state.progress.heartsUpdatedAt = Date().addingTimeInterval(-(10 * BryqoAppState.heartRegenInterval))

        state.applyHeartRegeneration()

        #expect(state.progress.hearts == BryqoAppState.heartsMax)
    }

    @Test("Full hearts report no pending regeneration")
    func fullHeartsHaveNoNextHeart() {
        let state = makeState()
        state.progress.hearts = BryqoAppState.heartsMax

        #expect(state.nextHeartAt == nil)
    }

    @Test("nextHeartAt is one interval after the regen baseline")
    func nextHeartAtIsOneInterval() throws {
        let state = makeState()
        let base = Date()
        state.progress.hearts = 3
        state.progress.heartsUpdatedAt = base

        let next = try #require(state.nextHeartAt)
        #expect(abs(next.timeIntervalSince(base) - BryqoAppState.heartRegenInterval) < 1)
    }

    // MARK: - Firestore merge

    @Test("Merge keeps the higher of local and remote progress")
    func mergeTakesMax() {
        let state = makeState()
        state.progress.xp = 100
        state.progress.streakDays = 3
        state.progress.perfectLessonCount = 2

        var remote = FirestoreUserSnapshot()
        remote.xp = 50
        remote.streakDays = 5
        remote.perfectLessonCount = 1
        remote.heartsUpdatedAt = Date()

        state.mergeRemote(remote)

        #expect(state.progress.xp == 100)
        #expect(state.progress.streakDays == 5)
        #expect(state.progress.perfectLessonCount == 2)
    }

    @Test("Merge unions completed lessons and achievements from both sides")
    func mergeUnionsSets() {
        let state = makeState()
        state.progress.completedLessonIds = ["local-a"]
        state.progress.earnedAchievementIds = ["ach-x"]

        var remote = FirestoreUserSnapshot()
        remote.completedLessonIds = ["remote-b"]
        remote.earnedAchievementIds = ["ach-y"]
        remote.heartsUpdatedAt = Date()

        state.mergeRemote(remote)

        #expect(state.progress.completedLessonIds == ["local-a", "remote-b"])
        #expect(state.progress.earnedAchievementIds == ["ach-x", "ach-y"])
    }

    @Test("Merge adopts the remote heart count and its timestamp")
    func mergeAdoptsRemoteHearts() {
        let state = makeState()
        state.progress.hearts = 5

        var remote = FirestoreUserSnapshot()
        remote.hearts = 2
        remote.heartsUpdatedAt = Date() // recent, so regeneration adds nothing

        state.mergeRemote(remote)

        #expect(state.progress.hearts == 2)
    }

    @Test("Merge prefers the more recent last-activity date")
    func mergePrefersNewerActivity() {
        let state = makeState()
        state.progress.lastActivityDate = daysAgo(2)

        var remote = FirestoreUserSnapshot()
        remote.lastActivityDate = daysAgo(1)
        remote.heartsUpdatedAt = Date()

        state.mergeRemote(remote)

        let merged = state.progress.lastActivityDate!
        #expect(Calendar.current.isDate(merged, inSameDayAs: daysAgo(1)))
    }

    // MARK: - Levels & daily goal (pure math)

    @Test("Current level reflects the XP thresholds", arguments: [
        (0, 1), (99, 1), (100, 2), (249, 2), (250, 3), (500, 4), (1000, 5)
    ])
    func currentLevelFromXp(xp: Int, expectedLevel: Int) {
        let state = makeState()
        state.progress.xp = xp

        #expect(state.currentLevel == expectedLevel)
    }

    @Test("XP progress within a level is the fraction toward the next threshold")
    func xpProgressWithinLevel() {
        let state = makeState()
        state.progress.xp = 150 // between level-2 (100) and level-3 (250)

        #expect(abs(state.xpProgressInLevel - (50.0 / 150.0)) < 0.0001)
    }

    @Test("Daily XP goal maps each onboarding tier", arguments: [
        (5, 15), (10, 30), (15, 50), (30, 75)
    ])
    func dailyXpGoalPerTier(minutes: Int, expected: Int) {
        #expect(BryqoAppState.xpGoal(for: minutes) == expected)
    }
}
