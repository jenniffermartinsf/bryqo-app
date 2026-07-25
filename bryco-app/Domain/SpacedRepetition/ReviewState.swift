import Foundation

/// Per-lesson spaced-repetition state, following the SM-2 algorithm.
///
/// Persisted locally as JSON inside SwiftData (`PersistedUserState.reviewStatesData`) and
/// mirrored to Firestore `lessonProgress/{lessonId}`. Kept as a plain `Codable` value type so
/// scheduling stays pure and unit-testable, independent of persistence.
struct ReviewState: Codable, Equatable, Identifiable {
    let lessonId: String
    /// Number of consecutive successful reviews.
    var repetitions: Int
    /// SM-2 easiness factor (never below `SM2Scheduler.minEase`).
    var easeFactor: Double
    /// Days scheduled until the next review.
    var intervalDays: Int
    var lastReviewedAt: Date
    var nextReviewAt: Date

    var id: String { lessonId }

    init(
        lessonId: String,
        repetitions: Int = 0,
        easeFactor: Double = SM2Scheduler.defaultEase,
        intervalDays: Int = 0,
        lastReviewedAt: Date = Date(),
        nextReviewAt: Date = Date()
    ) {
        self.lessonId = lessonId
        self.repetitions = repetitions
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.lastReviewedAt = lastReviewedAt
        self.nextReviewAt = nextReviewAt
    }

    /// Whether this lesson is due for review at `date`.
    func isDue(at date: Date = Date()) -> Bool {
        nextReviewAt <= date
    }
}
