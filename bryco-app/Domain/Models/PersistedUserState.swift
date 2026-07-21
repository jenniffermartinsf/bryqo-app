import Foundation
import SwiftData

// Versioned schema — ready for future migrations without rewriting everything.
enum BryqoSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [PersistedUserState.self] }

    @Model
    final class PersistedUserState {
        // UserProgress — Sets stored as [String] because SwiftData requires Codable collections
        var completedLessonIds: [String]
        var xp: Int
        var streakDays: Int
        var earnedMaterials: [String]
        var hearts: Int
        var lastActivityDate: Date?
        var earnedAchievementIds: [String]
        var perfectLessonCount: Int
        var streakFreezeCount: Int

        // OnboardingProfile — nil fields mean onboarding not yet completed
        var displayName: String?
        var experience: String?
        var goal: String?
        var dailyGoalMinutes: Int
        var accountCreatedDate: Date

        init() {
            completedLessonIds = []
            xp = 0
            streakDays = 0
            earnedMaterials = []
            hearts = 5
            lastActivityDate = nil
            earnedAchievementIds = []
            perfectLessonCount = 0
            streakFreezeCount = 1
            displayName = nil
            experience = nil
            goal = nil
            dailyGoalMinutes = 20
            accountCreatedDate = Date()
        }
    }
}

typealias PersistedUserState = BryqoSchemaV1.PersistedUserState

enum BryqoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [BryqoSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
