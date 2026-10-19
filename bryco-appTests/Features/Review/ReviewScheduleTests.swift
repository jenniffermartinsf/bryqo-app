import BryqoDomain
import Foundation
import Testing
@testable import bryco_app

/// Covers how SM-2 states become the sections and labels of the review schedule screen.
@MainActor
@Suite("Review schedule")
struct ReviewScheduleTests {

    private let now = Date(timeIntervalSince1970: 1_700_000_000)
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        return calendar
    }()
    private let titles = ["a": "Lição A", "b": "Lição B", "c": "Lição C"]

    private func state(_ id: String, inDays days: Int) -> ReviewState {
        ReviewState(lessonId: id, nextReviewAt: calendar.date(byAdding: .day, value: days, to: now)!)
    }

    private func make(_ states: [ReviewState]) -> ReviewSchedule {
        ReviewSchedule.make(from: states, lessonTitle: { titles[$0] }, now: now, calendar: calendar)
    }

    @Test("Due lessons go to 'review now', future ones to 'upcoming'")
    func splitsDueAndUpcoming() {
        let schedule = make([state("a", inDays: -1), state("b", inDays: 3)])

        #expect(schedule.dueNow.map(\.lessonId) == ["a"])
        #expect(schedule.upcoming.map(\.lessonId) == ["b"])
        #expect(schedule.dueNow.first?.isDue == true)
    }

    @Test("Upcoming lessons are sorted by their next review date")
    func sortsUpcoming() {
        let schedule = make([state("c", inDays: 10), state("a", inDays: 1), state("b", inDays: 6)])

        #expect(schedule.upcoming.map(\.lessonId) == ["a", "b", "c"])
    }

    @Test("The detail label names tomorrow and counts later days", arguments: [
        (1, "Amanhã"),
        (6, "Em 6 dias")
    ])
    func upcomingDetail(days: Int, prefix: String) {
        let detail = make([state("a", inDays: days)]).upcoming.first?.detail

        #expect(detail?.hasPrefix(prefix) == true)
    }

    @Test("States for unknown lessons are skipped")
    func skipsUnknownLessons() {
        let schedule = make([state("gone", inDays: 2)])

        #expect(schedule.isEmpty)
    }
}
