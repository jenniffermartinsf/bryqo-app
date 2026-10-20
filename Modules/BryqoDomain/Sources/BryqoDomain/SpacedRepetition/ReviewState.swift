import Foundation

/// Per-lesson spaced-repetition state, following the SM-2 algorithm.
///
/// A plain `Codable` value type so scheduling stays pure and unit-testable, independent of
/// persistence. The app stores it as one SwiftData `LessonReview` row per lesson.
public struct ReviewState: Codable, Equatable, Identifiable, Sendable {
    public let lessonId: String
    /// Number of consecutive successful reviews.
    public var repetitions: Int
    /// SM-2 easiness factor (never below `SM2Scheduler.minEase`).
    public var easeFactor: Double
    /// Days scheduled until the next review.
    public var intervalDays: Int
    public var lastReviewedAt: Date
    public var nextReviewAt: Date

    public var id: String { lessonId }

    public init(
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
    public func isDue(at date: Date = Date()) -> Bool {
        nextReviewAt <= date
    }
}
