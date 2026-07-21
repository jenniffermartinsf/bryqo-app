import Foundation
import UserNotifications

final class BryqoNotificationManager {
    private let center = UNUserNotificationCenter.current()
    private let reminderID = "bryqo.daily.reminder"

    // Requests permission and schedules the daily reminder.
    // Returns true if permission was granted.
    func requestAndSchedule() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        if granted { schedule() }
        return granted
    }

    func cancel() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
    }

    // Called on app foreground: re-adds the notification if it was somehow removed
    // (e.g., user studied the previous day and the cancellation happened, or device restarted).
    func ensureScheduledIfNeeded() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self, !requests.contains(where: { $0.identifier == self.reminderID }) else { return }
            self.schedule()
        }
    }

    // Cancels today's reminder (fired after studying) and re-adds it
    // so it fires at 19h on future days without firing again today.
    func cancelAndRescheduleFromTomorrow() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1
        components.hour = 19
        components.minute = 0

        let content = buildContent()
        // Non-repeating for tomorrow; ensureScheduledIfNeeded converts it to repeating on next launch.
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger))
    }

    private func schedule() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
        var components = DateComponents()
        components.hour = 19
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: reminderID, content: buildContent(), trigger: trigger))
    }

    private func buildContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Brix está esperando! 🦫"
        content.body = "Que tal uma lição de Lógica hoje? Não quebre sua sequência. 🔥"
        content.sound = .default
        return content
    }
}
