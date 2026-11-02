import Foundation
import Testing
@testable import bryco_app

/// The daily goal counts the XP earned *today*. `UserProgress` documents that it resets at
/// midnight; these tests check it does, however the new day starts.
@MainActor
@Suite("Daily goal", .tags(.gamification))
struct DailyGoalTests {
    private let state = BryqoAppState(inMemory: true)

    private func daysAgo(_ n: Int) -> Date {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -n, to: today)!
    }

    /// Studied yesterday and never closed the app: iOS kept it in memory overnight.
    private func studiedYesterday(xp: Int) {
        state.progress.lastActivityDate = daysAgo(1)
        state.progress.dailyXpEarned = xp
    }

    private func firstLesson() throws -> Lesson {
        try #require(BryqoContent.logicaUnit.lessons.first)
    }

    @Test("Coming back to the app on a new day starts the goal from zero")
    func newDayOnForeground() {
        studiedYesterday(xp: 40)

        state.appBecameActive()

        #expect(state.progress.dailyXpEarned == 0)
        #expect(state.dailyGoalProgress == 0)
    }

    @Test("A perfect review on a new day counts only today's XP")
    func reviewOnNewDay() throws {
        studiedYesterday(xp: 40)

        state.completeReview(try firstLesson(), mistakeCount: 0)

        #expect(state.progress.dailyXpEarned == 5)
    }

    @Test("A lesson on a new day counts only today's XP")
    func lessonOnNewDay() throws {
        studiedYesterday(xp: 40)
        let lesson = try firstLesson()

        state.completeLesson(lesson)

        #expect(state.progress.dailyXpEarned == lesson.xpReward)
    }

    @Test("Midnight passing with the app open starts the goal from zero")
    func midnightWithAppOpen() {
        studiedYesterday(xp: 40)

        state.startNewDayIfNeeded()
        state.startNewDayIfNeeded()

        #expect(state.progress.dailyXpEarned == 0)
        #expect(state.progress.lastActivityDate == daysAgo(1), "The streak still needs yesterday's date")
    }

    @Test("Coming back on the same day keeps today's XP")
    func sameDayOnForeground() {
        state.progress.lastActivityDate = daysAgo(0)
        state.progress.dailyXpEarned = 20

        state.appBecameActive()

        #expect(state.progress.dailyXpEarned == 20)
    }

    @Test("A review on the same day adds to today's XP")
    func reviewSameDay() throws {
        state.progress.lastActivityDate = daysAgo(0)
        state.progress.dailyXpEarned = 20

        state.completeReview(try firstLesson(), mistakeCount: 0)

        #expect(state.progress.dailyXpEarned == 25)
    }
}
