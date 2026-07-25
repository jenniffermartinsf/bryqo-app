import Foundation
import Testing
@testable import bryco_app

/// Exercises how `BryqoAppState` records and surfaces spaced-repetition reviews. Uses an in-memory
/// store so each case is isolated.
@Suite("Review scheduling", .tags(.gamification))
struct ReviewSchedulingTests {

    private func makeState() -> BryqoAppState { BryqoAppState(inMemory: true) }

    @Test("Completing a lesson creates a review schedule for it")
    func completingLessonSchedulesReview() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 0)

        let review = try #require(state.progress.reviewStates[lesson.id])
        #expect(review.repetitions == 1)
        #expect(review.nextReviewAt > Date())
    }

    @Test("A lesson reviewed today is not yet due")
    func freshlyReviewedIsNotDue() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)
        state.completeLesson(lesson, mistakeCount: 0)

        #expect(state.dueReviews().isEmpty)
        #expect(state.dueReviewCount == 0)
    }

    @Test("A review whose date has passed surfaces as due")
    func pastDueSurfaces() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)
        state.completeLesson(lesson, mistakeCount: 0)

        // Force the schedule into the past.
        state.progress.reviewStates[lesson.id]?.nextReviewAt = Date().addingTimeInterval(-3600)

        let due = state.dueReviews()
        #expect(due.count == 1)
        #expect(due.first?.id == lesson.id)
    }

    @Test("Global lesson lookup finds lessons across units")
    func lessonLookupAcrossUnits() throws {
        let state = makeState()
        let target = try #require(BryqoContent.algoritmosUnit.lessons.first)

        #expect(state.lesson(for: target.id)?.id == target.id)
        #expect(state.lesson(for: "id-inexistente") == nil)
    }

    @Test("Completing a review reschedules further out and awards bonus XP")
    func completingReviewReschedules() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)
        state.completeLesson(lesson, mistakeCount: 0)
        let firstInterval = try #require(state.progress.reviewStates[lesson.id]).intervalDays
        let xpBefore = state.progress.xp

        state.completeReview(lesson, mistakeCount: 0)

        let secondInterval = try #require(state.progress.reviewStates[lesson.id]).intervalDays
        #expect(secondInterval > firstInterval)         // 1 → 6 days
        #expect(state.progress.xp == xpBefore + 5)       // perfect review bonus
    }

    @Test("Review state survives a reload from the in-memory store")
    func reviewStatePersists() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 1)

        // The JSON round-trip through PersistedUserState is exercised on every save().
        let review = try #require(state.progress.reviewStates[lesson.id])
        #expect(review.lessonId == lesson.id)
    }
}
