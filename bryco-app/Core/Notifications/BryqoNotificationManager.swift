import Foundation
import UserNotifications

/// The part of the notification center the daily reminder uses. `UNUserNotificationCenter`
/// in the app, a recording fake in tests.
protocol NotificationScheduling: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func schedule(_ request: UNNotificationRequest)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func pendingNotificationRequests() async -> [UNNotificationRequest]
}

extension UNUserNotificationCenter: NotificationScheduling {
    func schedule(_ request: UNNotificationRequest) {
        add(request, withCompletionHandler: nil)
    }
}

final class BryqoNotificationManager {
    nonisolated static let reminderID = "bryqo.daily.reminder"
    nonisolated static let reminderHour = 19

    private let center: NotificationScheduling
    private let calendar: Calendar
    private let now: () -> Date

    /// - Parameters:
    ///   - center: where reminders are scheduled. The system notification center by default.
    ///   - calendar, now: what "today" is. Injected so tests can pick any date.
    init(
        center: NotificationScheduling = UNUserNotificationCenter.current(),
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) {
        self.center = center
        self.calendar = calendar
        self.now = now
    }

    // Requests permission and schedules the daily reminder.
    // Returns true if permission was granted.
    func requestAndSchedule() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        if granted { schedule() }
        return granted
    }

    func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderID])
    }

    // Called on app foreground: re-adds the notification if it was somehow removed
    // (e.g., user studied the previous day and the cancellation happened, or device restarted).
    func ensureScheduledIfNeeded() async {
        let requests = await center.pendingNotificationRequests()
        guard !requests.contains(where: { $0.identifier == Self.reminderID }) else { return }
        schedule()
    }

    // Cancels today's reminder (fired after studying) and re-adds it
    // so it fires at 19h on future days without firing again today.
    func cancelAndRescheduleFromTomorrow() {
        cancel()

        // Calendar arithmetic, not `day + 1`: the day after October 31 is November 1, not October 32.
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now())) else {
            return
        }
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = Self.reminderHour
        components.minute = 0

        // Non-repeating for tomorrow; ensureScheduledIfNeeded converts it to repeating on next launch.
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.schedule(UNNotificationRequest(identifier: Self.reminderID, content: buildContent(), trigger: trigger))
    }

    private func schedule() {
        cancel()
        var components = DateComponents()
        components.hour = Self.reminderHour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.schedule(UNNotificationRequest(identifier: Self.reminderID, content: buildContent(), trigger: trigger))
    }

    private func buildContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Brix está esperando! 🦫"
        content.body = "Que tal uma lição de Lógica hoje? Não quebre sua sequência. 🔥"
        content.sound = .default
        return content
    }
}
