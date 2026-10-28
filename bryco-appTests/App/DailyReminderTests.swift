import Foundation
import Testing
import UserNotifications
@testable import bryco_app

/// Stands in for `UNUserNotificationCenter`: keeps scheduled requests in memory and grants or
/// denies permission on demand.
@MainActor
final class FakeNotificationCenter: NotificationScheduling {
    var grantsPermission = true
    private(set) var pending: [UNNotificationRequest] = []
    private(set) var permissionRequests = 0

    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        permissionRequests += 1
        return grantsPermission
    }

    func schedule(_ request: UNNotificationRequest) {
        pending.removeAll { $0.identifier == request.identifier }
        pending.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        pending.removeAll { identifiers.contains($0.identifier) }
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] { pending }

    var reminderTrigger: UNCalendarNotificationTrigger? {
        pending.first { $0.identifier == BryqoNotificationManager.reminderID }?.trigger as? UNCalendarNotificationTrigger
    }
}

@MainActor
@Suite("Daily reminder")
struct DailyReminderTests {
    let center = FakeNotificationCenter()
    let calendar = Calendar(identifier: .gregorian)

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 20) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func manager(today: Date) -> BryqoNotificationManager {
        BryqoNotificationManager(center: center, calendar: calendar, now: { today })
    }

    @Test("After studying, the next reminder is tomorrow at 19h, even across a month or a year", arguments: [
        (today: (2026, 10, 27), tomorrow: (2026, 10, 28)),
        (today: (2026, 10, 31), tomorrow: (2026, 11, 1)),
        (today: (2026, 12, 31), tomorrow: (2027, 1, 1)),
        (today: (2028, 2, 28), tomorrow: (2028, 2, 29)),
    ])
    func rescheduleFromTomorrow(today: (Int, Int, Int), tomorrow: (Int, Int, Int)) throws {
        let today = date(today.0, today.1, today.2)

        manager(today: today).cancelAndRescheduleFromTomorrow()

        let trigger = try #require(center.reminderTrigger)
        #expect(!trigger.repeats)
        let fires = trigger.dateComponents
        // Compared as components: nextTriggerDate() depends on the real clock.
        #expect([fires.year, fires.month, fires.day, fires.hour] == [tomorrow.0, tomorrow.1, tomorrow.2, 19])
    }

    @Test("Studying replaces the pending reminder instead of adding a second one")
    func noDuplicateReminder() async {
        let manager = manager(today: date(2026, 10, 27))
        _ = await manager.requestAndSchedule()

        manager.cancelAndRescheduleFromTomorrow()

        #expect(center.pending.count == 1)
        #expect(center.reminderTrigger?.repeats == false)
    }

    @Test("Turning the reminder on schedules it every day at 19h")
    func enableSchedulesDailyReminder() async throws {
        let manager = manager(today: date(2026, 10, 27))

        #expect(await manager.requestAndSchedule())

        let trigger = try #require(center.reminderTrigger)
        #expect(trigger.repeats)
        #expect(trigger.dateComponents.hour == 19)
    }

    @Test("Opening the app re-adds a missing reminder and leaves an existing one alone")
    func ensureScheduled() async {
        let manager = manager(today: date(2026, 10, 27))

        await manager.ensureScheduledIfNeeded()
        #expect(center.reminderTrigger?.repeats == true)

        manager.cancelAndRescheduleFromTomorrow()
        await manager.ensureScheduledIfNeeded()
        #expect(center.reminderTrigger?.repeats == false)
        #expect(center.pending.count == 1)
    }

    @Test("If permission is denied, the switch goes back off and nothing is scheduled")
    func deniedPermissionTurnsSwitchOff() async {
        center.grantsPermission = false
        let appState = BryqoAppState(inMemory: true, notificationManager: manager(today: date(2026, 10, 27)))
        appState.notificationsEnabled = true

        await appState.scheduleReminderIfAllowed()

        #expect(!appState.notificationsEnabled)
        #expect(center.permissionRequests == 1)
        #expect(center.pending.isEmpty)
    }

    @Test("Completing a lesson with the reminder on moves it to tomorrow")
    func completingLessonMovesReminder() throws {
        let appState = BryqoAppState(inMemory: true, notificationManager: manager(today: date(2026, 10, 31)))
        appState.notificationsEnabled = true
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        appState.completeLesson(lesson)

        let fires = try #require(center.reminderTrigger).dateComponents
        #expect([fires.year, fires.month, fires.day, fires.hour] == [2026, 11, 1, 19])
    }

    @Test("Turning the reminder off cancels it")
    func disableCancels() async {
        let appState = BryqoAppState(inMemory: true, notificationManager: manager(today: date(2026, 10, 27)))
        _ = await appState.notificationManager.requestAndSchedule()

        appState.setNotificationsEnabled(false)

        #expect(center.pending.isEmpty)
    }
}
