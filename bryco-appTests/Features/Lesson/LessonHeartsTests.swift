import Foundation
import Testing
@testable import bryco_app

/// Hearts lost inside a lesson must reach the app, one by one. Before, `LessonView` forwarded
/// them in an `onChange(of: hearts)`, which runs once per change: a trace step that took three
/// hearts at once charged the app for one.
@MainActor
@Suite("Lesson hearts", .tags(.gamification))
struct LessonHeartsTests {
    /// Every charge `LessonViewModel` sends to the app, in order.
    private final class Charges {
        var values: [Int] = []
    }

    private let charges = Charges()

    private func lesson(_ steps: LessonStep...) -> Lesson { LessonFixtures.lesson(steps: steps) }

    private func makeViewModel(_ lesson: Lesson, hearts: Int) -> LessonViewModel {
        LessonViewModel(lesson: lesson, initialHearts: hearts, loseHearts: { [charges] in charges.values.append($0) })
    }

    private let choice = LessonFixtures.singleChoiceStep(
        correct: "ok", options: [LessonFixtures.option("ok"), LessonFixtures.option("no")]
    )

    // MARK: - Success: nothing to charge

    @Test("A correct answer charges no heart")
    func correctAnswerChargesNothing() {
        let vm = makeViewModel(lesson(choice), hearts: 5)

        vm.selectOption(LessonFixtures.option("ok"))
        vm.verify()

        #expect(vm.xpEarned == 10)
        #expect(charges.values.isEmpty)
    }

    @Test("A flawless trace step charges no heart")
    func flawlessTraceChargesNothing() {
        let vm = makeViewModel(lesson(LessonFixtures.traceStep(), choice), hearts: 5)

        vm.applyTraceResult(mistakes: 0, correct: 3)

        #expect(charges.values.isEmpty)
        #expect(vm.xpEarned == 30)
    }

    // MARK: - Errors: each heart lost is charged

    @Test("A wrong answer charges exactly one heart")
    func wrongAnswerChargesOne() {
        let vm = makeViewModel(lesson(choice), hearts: 5)

        vm.selectOption(LessonFixtures.option("no"))
        vm.verify()
        vm.verify()

        #expect(charges.values == [1])
    }

    @Test("A trace step charges every heart it took, in one go", arguments: [1, 2, 3])
    func traceChargesEveryMistake(mistakes: Int) {
        let vm = makeViewModel(lesson(LessonFixtures.traceStep(), choice), hearts: 5)

        vm.applyTraceResult(mistakes: mistakes, correct: 3 - mistakes)

        #expect(vm.hearts == 5 - mistakes)
        #expect(charges.values == [mistakes])
    }

    @Test("Mistakes beyond the hearts left are not charged")
    func chargesOnlyHeartsLeft() {
        let vm = makeViewModel(lesson(LessonFixtures.traceStep(), choice), hearts: 1)

        vm.applyTraceResult(mistakes: 3, correct: 0)

        #expect(vm.hearts == 0)
        #expect(charges.values == [1])
    }

    // MARK: - Out of hearts

    @Test("The lesson stops only after the last heart's feedback was read")
    func outOfHeartsAfterFeedback() {
        let vm = makeViewModel(lesson(choice, choice), hearts: 1)

        vm.selectOption(LessonFixtures.option("no"))
        vm.verify()
        #expect(!vm.isOutOfHearts, "The feedback for the wrong answer is still on screen")

        vm.advance()
        #expect(vm.isOutOfHearts)
    }

    @Test("Losing the last heart on the last step still finishes the lesson")
    func lastStepFinishesWithoutHearts() {
        let vm = makeViewModel(lesson(choice), hearts: 1)

        vm.selectOption(LessonFixtures.option("no"))
        vm.verify()
        vm.advance()

        #expect(vm.isComplete)
        #expect(!vm.isOutOfHearts)
    }

    // MARK: - With the app

    @Test("The app ends the lesson with the same hearts the lesson shows")
    func appMatchesLesson() {
        let appState = BryqoAppState(inMemory: true)
        appState.progress.hearts = 5
        let vm = LessonViewModel(
            lesson: lesson(choice, LessonFixtures.traceStep()),
            initialHearts: appState.progress.hearts,
            loseHearts: { appState.loseHearts($0) }
        )

        vm.selectOption(LessonFixtures.option("no"))
        vm.verify()
        vm.advance()
        vm.applyTraceResult(mistakes: 2, correct: 1)

        #expect(vm.hearts == 2)
        #expect(appState.progress.hearts == vm.hearts)
    }

    @Test("The app never goes below zero hearts")
    func appClampsAtZero() {
        let appState = BryqoAppState(inMemory: true)
        appState.progress.hearts = 2

        appState.loseHearts(3)
        appState.loseHearts()

        #expect(appState.progress.hearts == 0)
    }
}
