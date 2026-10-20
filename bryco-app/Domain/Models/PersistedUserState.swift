import BryqoDomain
import Foundation
import SwiftData

enum BryqoSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV1.PersistedUserState.self] }
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int; var dailyMinutesStudied: Int
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
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
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int; var dailyXpEarned: Int
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
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
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int; var dailyXpEarned: Int; var heartsUpdatedAt: Date
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
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

enum BryqoSchemaV4: VersionedSchema {
    static let versionIdentifier = Schema.Version(4, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV4.PersistedUserState.self] }
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyMinutesStudied: Int   // real session time, used for the daily goal ring
        var dailyXpEarned: Int         // XP earned today, kept for Firestore analytics
        var heartsUpdatedAt: Date
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1
            dailyMinutesStudied = 0; dailyXpEarned = 0
            heartsUpdatedAt = Date()
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }
}

enum BryqoSchemaV5: VersionedSchema {
    static let versionIdentifier = Schema.Version(5, 0, 0)
    static var models: [any PersistentModel.Type] { [BryqoSchemaV5.PersistedUserState.self] }
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyMinutesStudied: Int   // real session time, used for the daily goal ring
        var dailyXpEarned: Int         // XP earned today, kept for Firestore analytics
        var heartsUpdatedAt: Date
        var reviewStatesData: Data = Data()   // JSON-encoded [ReviewState] for spaced repetition
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1
            dailyMinutesStudied = 0; dailyXpEarned = 0
            heartsUpdatedAt = Date()
            reviewStatesData = Data()
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }
}

enum BryqoSchemaV6: VersionedSchema {
    static let versionIdentifier = Schema.Version(6, 0, 0)
    static var models: [any PersistentModel.Type] {
        [BryqoSchemaV6.PersistedUserState.self, BryqoSchemaV6.LessonReview.self]
    }
    @Model final class PersistedUserState {
        var completedLessonIds: [String]; var xp: Int; var streakDays: Int
        var earnedMaterials: [String]; var hearts: Int; var lastActivityDate: Date?
        var earnedAchievementIds: [String]; var perfectLessonCount: Int
        var streakFreezeCount: Int
        var dailyMinutesStudied: Int   // real session time, used for the daily goal ring
        var dailyXpEarned: Int         // XP earned today, kept for Firestore analytics
        var heartsUpdatedAt: Date
        var displayName: String?; var experience: String?; var goal: String?
        var dailyGoalMinutes: Int; var accountCreatedDate: Date
        init() {
            completedLessonIds = []; xp = 0; streakDays = 0; earnedMaterials = []
            hearts = 5; lastActivityDate = nil; earnedAchievementIds = []
            perfectLessonCount = 0; streakFreezeCount = 1
            dailyMinutesStudied = 0; dailyXpEarned = 0
            heartsUpdatedAt = Date()
            displayName = nil; experience = nil; goal = nil
            dailyGoalMinutes = 20; accountCreatedDate = Date()
        }
    }

    /// One row per lesson in spaced repetition. Replaces the JSON blob stored in
    /// `PersistedUserState.reviewStatesData` up to V5, so reviews can be queried in the store.
    @Model final class LessonReview {
        #Unique<LessonReview>([\.lessonId])
        #Index<LessonReview>([\.nextReviewAt])

        var lessonId: String
        var repetitions: Int
        var easeFactor: Double
        var intervalDays: Int
        var lastReviewedAt: Date
        var nextReviewAt: Date

        init(_ state: ReviewState) {
            lessonId = state.lessonId
            repetitions = state.repetitions
            easeFactor = state.easeFactor
            intervalDays = state.intervalDays
            lastReviewedAt = state.lastReviewedAt
            nextReviewAt = state.nextReviewAt
        }

        /// The pure value the SM-2 scheduler works with.
        var reviewState: ReviewState {
            ReviewState(
                lessonId: lessonId,
                repetitions: repetitions,
                easeFactor: easeFactor,
                intervalDays: intervalDays,
                lastReviewedAt: lastReviewedAt,
                nextReviewAt: nextReviewAt
            )
        }

        func apply(_ state: ReviewState) {
            repetitions = state.repetitions
            easeFactor = state.easeFactor
            intervalDays = state.intervalDays
            lastReviewedAt = state.lastReviewedAt
            nextReviewAt = state.nextReviewAt
        }
    }
}

typealias PersistedUserState = BryqoSchemaV6.PersistedUserState
typealias LessonReview = BryqoSchemaV6.LessonReview

enum BryqoMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BryqoSchemaV1.self, BryqoSchemaV2.self, BryqoSchemaV3.self, BryqoSchemaV4.self, BryqoSchemaV5.self, BryqoSchemaV6.self]
    }
    static var stages: [MigrationStage] {
        [
            MigrationStage.lightweight(fromVersion: BryqoSchemaV1.self, toVersion: BryqoSchemaV2.self),
            MigrationStage.lightweight(fromVersion: BryqoSchemaV2.self, toVersion: BryqoSchemaV3.self),
            MigrationStage.lightweight(fromVersion: BryqoSchemaV3.self, toVersion: BryqoSchemaV4.self),
            MigrationStage.lightweight(fromVersion: BryqoSchemaV4.self, toVersion: BryqoSchemaV5.self),
            migrateV5toV6
        ]
    }

    /// Moves review states out of the V5 JSON blob into one `LessonReview` row each.
    /// `willMigrate` still sees the V5 models, so it reads the blob; `didMigrate` runs on the
    /// V6 store, where the new rows can be inserted.
    static let migrateV5toV6 = MigrationStage.custom(
        fromVersion: BryqoSchemaV5.self,
        toVersion: BryqoSchemaV6.self,
        willMigrate: { context in
            let users = try context.fetch(FetchDescriptor<BryqoSchemaV5.PersistedUserState>())
            ReviewMigrationBuffer.pending = users.flatMap { ReviewMigrationBuffer.decode($0.reviewStatesData) }
        },
        didMigrate: { context in
            var seen = Set<String>()
            for state in ReviewMigrationBuffer.pending where seen.insert(state.lessonId).inserted {
                context.insert(BryqoSchemaV6.LessonReview(state))
            }
            ReviewMigrationBuffer.pending = []
            try context.save()
        }
    )
}

/// Carries decoded review states between the two halves of the V5 → V6 migration.
enum ReviewMigrationBuffer {
    nonisolated(unsafe) static var pending: [ReviewState] = []

    static func decode(_ data: Data) -> [ReviewState] {
        guard !data.isEmpty else { return [] }
        return (try? JSONDecoder().decode([ReviewState].self, from: data)) ?? []
    }
}
