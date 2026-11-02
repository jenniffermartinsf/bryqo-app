import Foundation
import Testing
@testable import bryco_app

/// Which lesson a completion opens up: the map reveals exactly that one, once.
@MainActor
@Suite("Lesson unlock", .tags(.gamification))
struct LessonUnlockTests {
    let state = BryqoAppState(inMemory: true)

    private var units: [LearningUnit] { state.content.units }

    @Test("Finishing a lesson unlocks the next one in the unit")
    func nextInUnit() throws {
        let lessons = try #require(units.first).lessons

        state.completeLesson(lessons[0])

        #expect(state.takeJustUnlockedLesson() == lessons[1].id)
    }

    @Test("Finishing a unit's last lesson unlocks the first lesson of the next unit")
    func nextUnit() throws {
        try #require(units.count >= 2)
        let first = units[0].lessons
        for lesson in first.dropLast() { state.completeLesson(lesson) }
        _ = state.takeJustUnlockedLesson()

        state.completeLesson(try #require(first.last))

        #expect(state.takeJustUnlockedLesson() == units[1].lessons.first?.id)
    }

    @Test("The reveal plays once")
    func takenOnce() throws {
        state.completeLesson(try #require(units.first?.lessons.first))

        _ = state.takeJustUnlockedLesson()

        #expect(state.takeJustUnlockedLesson() == nil)
    }

    @Test("Finishing a lesson again unlocks nothing")
    func repeatUnlocksNothing() throws {
        let lesson = try #require(units.first?.lessons.first)
        state.completeLesson(lesson)
        _ = state.takeJustUnlockedLesson()

        state.completeLesson(lesson)

        #expect(state.takeJustUnlockedLesson() == nil)
    }

    @Test("A review unlocks nothing")
    func reviewUnlocksNothing() throws {
        let lesson = try #require(units.first?.lessons.first)
        state.completeLesson(lesson)
        _ = state.takeJustUnlockedLesson()

        state.completeReview(lesson)

        #expect(state.takeJustUnlockedLesson() == nil)
    }
}
