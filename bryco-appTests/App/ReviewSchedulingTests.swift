import Foundation
import BryqoDomain
import SwiftData
import Testing
@testable import bryco_app

/// Exercises how `BryqoAppState` records and surfaces spaced-repetition reviews. Uses an in-memory
/// store so each case is isolated.
@MainActor
@Suite("Review scheduling", .tags(.gamification))
struct ReviewSchedulingTests {

    private func makeState() -> BryqoAppState { BryqoAppState(inMemory: true) }

    @Test("Completing a lesson creates a review schedule for it")
    func completingLessonSchedulesReview() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 0)

        let review = try #require(state.review(for: lesson.id))
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
        state.review(for: lesson.id)?.nextReviewAt = Date().addingTimeInterval(-3600)
        state.reviewsChanged()

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
        let firstInterval = try #require(state.review(for: lesson.id)).intervalDays
        let xpBefore = state.progress.xp

        state.completeReview(lesson, mistakeCount: 0)

        let secondInterval = try #require(state.review(for: lesson.id)).intervalDays
        #expect(secondInterval > firstInterval)         // 1 → 6 days
        #expect(state.progress.xp == xpBefore + 5)       // perfect review bonus
    }

    @Test("Each lesson has exactly one review row, updated in place")
    func oneRowPerLesson() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)

        state.completeLesson(lesson, mistakeCount: 1)
        state.completeReview(lesson, mistakeCount: 0)

        let rows = try state.modelContainer.mainContext.fetch(FetchDescriptor<LessonReview>())
        #expect(rows.count == 1)
        #expect(rows.first?.repetitions == 2)
    }

    @Test("Due reviews come back most overdue first")
    func dueReviewsAreSorted() throws {
        let state = makeState()
        let lessons = Array(BryqoContent.logicaUnit.lessons.prefix(2))
        try #require(lessons.count == 2)
        for lesson in lessons { state.scheduleReview(lessonId: lesson.id, mistakeCount: 0) }

        state.review(for: lessons[0].id)?.nextReviewAt = Date().addingTimeInterval(-60)
        state.review(for: lessons[1].id)?.nextReviewAt = Date().addingTimeInterval(-7200)
        state.reviewsChanged()

        #expect(state.dueReviews().map(\.id) == [lessons[1].id, lessons[0].id])
        #expect(state.dueReviewCount == 2)
    }

    @Test("Resetting reviews deletes every row but keeps lessons and XP")
    func resetReviewsDeletesRows() throws {
        let state = makeState()
        let lesson = try #require(BryqoContent.logicaUnit.lessons.first)
        state.completeLesson(lesson, mistakeCount: 0)
        let xp = state.progress.xp

        state.resetReviews()

        #expect(state.review(for: lesson.id) == nil)
        #expect(try state.modelContainer.mainContext.fetchCount(FetchDescriptor<LessonReview>()) == 0)
        #expect(state.isLessonCompleted(lesson))
        #expect(state.progress.xp == xp)
    }
}
