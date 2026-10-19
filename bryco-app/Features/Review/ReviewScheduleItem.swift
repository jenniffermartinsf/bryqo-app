import BryqoDomain
import Foundation

/// One row of the review schedule: a lesson and when it comes back for review.
nonisolated struct ReviewScheduleItem: Hashable, Sendable {
    let lessonId: String
    let title: String
    let detail: String
    let isDue: Bool
}

/// The schedule split into what can be reviewed now and what comes later.
nonisolated struct ReviewSchedule: Equatable, Sendable {
    var dueNow: [ReviewScheduleItem] = []
    var upcoming: [ReviewScheduleItem] = []

    var isEmpty: Bool { dueNow.isEmpty && upcoming.isEmpty }

    /// Builds the schedule from SM-2 states. Pure, so `now` and `calendar` are injected for tests.
    static func make(
        from states: [ReviewState],
        lessonTitle: (String) -> String?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> ReviewSchedule {
        var schedule = ReviewSchedule()
        for state in states.sorted(by: { $0.nextReviewAt < $1.nextReviewAt }) {
            guard let title = lessonTitle(state.lessonId) else { continue }
            if state.isDue(at: now) {
                schedule.dueNow.append(ReviewScheduleItem(
                    lessonId: state.lessonId, title: title, detail: "Disponível agora", isDue: true
                ))
            } else {
                schedule.upcoming.append(ReviewScheduleItem(
                    lessonId: state.lessonId,
                    title: title,
                    detail: upcomingDetail(for: state.nextReviewAt, now: now, calendar: calendar),
                    isDue: false
                ))
            }
        }
        return schedule
    }

    private static func upcomingDetail(for date: Date, now: Date, calendar: Calendar) -> String {
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: date)
        ).day ?? 0
        let relative = switch days {
        case ...0: "Hoje"
        case 1: "Amanhã"
        default: "Em \(days) dias"
        }
        let day = date.formatted(
            .dateTime.day().month(.abbreviated).locale(Locale(identifier: "pt_BR"))
        )
        return "\(relative) · \(day)"
    }
}
