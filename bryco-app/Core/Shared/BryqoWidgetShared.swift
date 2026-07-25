import Foundation

/// Data shared between the app and the WidgetKit extension.
///
/// **This file must belong to BOTH targets** (app + widget). Add it to the widget target's
/// membership after creating the extension. The app writes a small snapshot to an App Group
/// container on every progress change; the widget reads that mirror — never Firestore/SwiftData
/// directly — as the plan requires.
struct BryqoWidgetSnapshot: Codable, Equatable {
    var streakDays: Int
    var dailyXpEarned: Int
    var dailyGoalXp: Int
    var updatedAt: Date

    /// Fraction of today's XP goal completed (0…1).
    var dailyGoalProgress: Double {
        guard dailyGoalXp > 0 else { return 0 }
        return min(1, Double(dailyXpEarned) / Double(dailyGoalXp))
    }

    static let placeholder = BryqoWidgetSnapshot(
        streakDays: 5, dailyXpEarned: 20, dailyGoalXp: 30, updatedAt: Date()
    )
}

/// Reads/writes the widget snapshot in the shared App Group container.
enum BryqoSharedStore {
    /// Must match the App Group configured in both targets' entitlements.
    static let appGroupId = "group.jenniffermartinsf.bryco-app"
    static let snapshotKey = "bryqo.widget.snapshot"

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    static func write(_ snapshot: BryqoWidgetSnapshot) {
        guard let defaults, let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func read() -> BryqoWidgetSnapshot? {
        guard let defaults, let data = defaults.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(BryqoWidgetSnapshot.self, from: data)
    }
}
