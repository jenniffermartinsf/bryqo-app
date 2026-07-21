import Foundation
import SwiftData

enum BryqoSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV1.PersistedUserState.self] }

    @Model
    final class PersistedUserState {
        var completedLessonIds: [String]
        var xp: Int
        var streakDays: Int
        var earnedMaterials: [String]
        var hearts: Int
        var lastActivityDate: Date?
        var earnedAchievementIds: [String]
        var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyMinutesStudied: Int
        var displayName: String?
        var experience: String?
        var goal: String?
        var dailyGoalMinutes: Int
        var accountCreatedDate: Date

        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1; dailyMinutesStudied = 0
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }
}

enum BryqoSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV2.PersistedUserState.self] }

    @Model
    final class PersistedUserState {
        var completedLessonIds: [String]
        var xp: Int
        var streakDays: Int
        var earnedMaterials: [String]
        var hearts: Int
        var lastActivityDate: Date?
        var earnedAchievementIds: [String]
        var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyXpEarned: Int
        var displayName: String?
        var experience: String?
        var goal: String?
        var dailyGoalMinutes: Int
        var accountCreatedDate: Date

        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1; dailyXpEarned = 0
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }
}

enum BryqoSchemaV3: VersionedSchema {
    static let versionIdentifier = Schema.Version(3, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV3.PersistedUserState.self] }

    @Model
    final class PersistedUserState {
        var completedLessonIds: [String]
        var xp: Int
        var streakDays: Int
        var earnedMaterials: [String]
        var hearts: Int
        var lastActivityDate: Date?
        var earnedAchievementIds: [String]
        var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyXpEarned: Int
        // Hearts regeneration baseline — starts regen timer when a heart is lost
        var heartsUpdatedAt: Date
        var displayName: String?
        var experience: String?
        var goal: String?
        var dailyGoalMinutes: Int
        var accountCreatedDate: Date

        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1; dailyXpEarned = 0
            heartsUpdatedAt = Date()
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }
}

typealias PersistedUserState = BryqoSchemaV3.PersistedUserState

enum BryqoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BryqoSchemaV1.self, BryqoSchemaV2.self, BryqoSchemaV3.self]
    }
    static var stages: [MigrationStage] {
        [
            MigrationStage.lightweight(fromVersion: BryqoSchemaV1.self, toVersion: BryqoSchemaV2.self),
            MigrationStage.lightweight(fromVersion: BryqoSchemaV2.self, toVersion: BryqoSchemaV3.self)
        ]
    }
}
