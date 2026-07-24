import Testing
@testable import bryco_app

/// Covers the in-lesson gamification loop. `LessonViewModel` is a plain `@Observable`
/// with no external dependencies, so every case is fully isolated and repeatable.
@Suite("LessonViewModel", .tags(.gamification))
struct LessonViewModelTests {

    // MARK: - Initial state

    @Test("Starts on the first step with the supplied hearts")
    func startsAtFirstStep() {
        let vm = LessonViewModel(lesson: LessonFixtures.standardLesson(), initialHearts: 5)

        #expect(vm.stepIndex == 0)
        #expect(vm.hearts == 5)
        #expect(vm.mistakeCount == 0)
        #expect(vm.xpEarned == 0)
        #expect(vm.isComplete == false)
        #expect(vm.progress == 0)
    }

    // MARK: - Selection

    @Test("Single-choice selection replaces the previous choice")
    func singleChoiceReplacesSelection() {
        let step = LessonFixtures.singleChoiceStep(correct: "b", options: [.init(id: "a", text: "a"), .init(id: "b", text: "b")])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(.init(id: "a", text: "a"))
        vm.selectOption(.init(id: "b", text: "b"))

        #expect(vm.selectedOptionIds == ["b"], "A newer single choice must replace the earlier one")
    }

    @Test("Exercise steps cannot be verified until an option is chosen")
    func canVerifyRequiresSelection() {
        let step = LessonFixtures.singleChoiceStep(correct: "b", options: [.init(id: "a", text: "a"), .init(id: "b", text: "b")])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        #expect(vm.canVerify == false)
        vm.selectOption(.init(id: "a", text: "a"))
        #expect(vm.canVerify == true)
    }

    // MARK: - Verify

    @Test("A correct answer awards XP and keeps every heart")
    func correctAnswerAwardsXp() {
        let step = LessonFixtures.singleChoiceStep(correct: "b", options: [.init(id: "a", text: "a"), .init(id: "b", text: "b")])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(.init(id: "b", text: "b"))
        vm.verify()

        #expect(vm.isAnswerCorrect)
        #expect(vm.hasAnswered)
        #expect(vm.xpEarned == 10)
        #expect(vm.correctCount == 1)
        #expect(vm.hearts == 5, "A correct answer must not cost a heart")
        #expect(vm.mistakeCount == 0)
    }

    @Test("A wrong answer costs a heart and records a mistake")
    func wrongAnswerLosesHeart() {
        let step = LessonFixtures.singleChoiceStep(correct: "b", options: [.init(id: "a", text: "a"), .init(id: "b", text: "b")])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(.init(id: "a", text: "a"))
        vm.verify()

        #expect(vm.isAnswerCorrect == false)
        #expect(vm.hearts == 4)
        #expect(vm.mistakeCount == 1)
        #expect(vm.xpEarned == 0)
    }

    @Test("Hearts never fall below zero")
    func heartsClampAtZero() {
        let lesson = LessonFixtures.lesson(steps: [
            LessonFixtures.singleChoiceStep(id: "a", correct: "ok", options: [.init(id: "ok", text: "ok"), .init(id: "no", text: "no")]),
            LessonFixtures.singleChoiceStep(id: "b", correct: "ok", options: [.init(id: "ok", text: "ok"), .init(id: "no", text: "no")])
        ])
        let vm = LessonViewModel(lesson: lesson, initialHearts: 1)

        vm.selectOption(.init(id: "no", text: "no"))
        vm.verify()
        vm.advance()
        vm.selectOption(.init(id: "no", text: "no"))
        vm.verify()

        #expect(vm.hearts == 0)
        #expect(vm.mistakeCount == 2)
    }

    @Test("Verifying twice on the same step applies the result only once")
    func verifyIsIdempotentPerStep() {
        let step = LessonFixtures.singleChoiceStep(correct: "b", options: [.init(id: "a", text: "a"), .init(id: "b", text: "b")])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(.init(id: "a", text: "a"))
        vm.verify()
        vm.verify()

        #expect(vm.hearts == 4, "Re-verifying a wrong answer must not drain a second heart")
        #expect(vm.mistakeCount == 1)
    }

    @Test("Concept steps have no exercise, so verifying is a no-op")
    func conceptStepDoesNotConsumeHearts() {
        let vm = LessonViewModel(
            lesson: LessonFixtures.lesson(steps: [LessonFixtures.conceptStep()]),
            initialHearts: 5
        )

        #expect(vm.canVerify)
        #expect(vm.isAnswerCorrect)
        vm.verify()

        #expect(vm.hearts == 5)
        #expect(vm.hasAnswered == false)
    }

    // MARK: - Ordering

    @Test("Ordering is correct only in the exact sequence")
    func orderingRequiresExactSequence() {
        let options = [LessonFixtures.option("1"), LessonFixtures.option("2"), LessonFixtures.option("3")]
        let step = LessonFixtures.orderingStep(options: options, correctOrder: ["1", "2", "3"])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(options[1]) // 2
        vm.selectOption(options[0]) // 1
        vm.selectOption(options[2]) // 3
        #expect(vm.isAnswerCorrect == false, "Order 2,1,3 must be wrong")

        vm.selectOption(options[1]) // toggles 2 off, leaving 1,3
        vm.selectOption(options[1]) // re-adds 2 at the end -> 1,3,2 still wrong
        #expect(vm.selectedOptionIds == ["1", "3", "2"])
    }

    @Test("Ordering selected in the right order is correct")
    func orderingInRightOrderIsCorrect() {
        let options = [LessonFixtures.option("1"), LessonFixtures.option("2"), LessonFixtures.option("3")]
        let step = LessonFixtures.orderingStep(options: options, correctOrder: ["1", "2", "3"])
        let vm = LessonViewModel(lesson: LessonFixtures.lesson(steps: [step]), initialHearts: 5)

        vm.selectOption(options[0])
        vm.selectOption(options[1])
        vm.selectOption(options[2])

        #expect(vm.isAnswerCorrect)
    }

    // MARK: - Progression

    @Test("Advancing moves to the next step and clears the answer state")
    func advanceResetsAnswerState() {
        let vm = LessonViewModel(lesson: LessonFixtures.standardLesson(), initialHearts: 5)

        vm.advance() // leave concept step 0
        vm.selectOption(.init(id: "b", text: "b"))
        vm.verify()
        vm.advance()

        #expect(vm.stepIndex == 2)
        #expect(vm.hasAnswered == false)
        #expect(vm.selectedOptionIds.isEmpty)
    }

    @Test("Advancing past the last step completes the lesson")
    func advanceOnLastStepCompletes() {
        let vm = LessonViewModel(
            lesson: LessonFixtures.lesson(steps: [LessonFixtures.conceptStep()]),
            initialHearts: 5
        )

        #expect(vm.isLastStep)
        vm.advance()

        #expect(vm.isComplete)
    }

    @Test("Progress is the fraction of steps already left behind", arguments: [
        (0, 0.0), (1, 1.0 / 3.0), (2, 2.0 / 3.0)
    ])
    func progressReflectsPosition(stepIndex: Int, expected: Double) {
        let vm = LessonViewModel(lesson: LessonFixtures.standardLesson(), initialHearts: 5)
        for _ in 0..<stepIndex { vm.advance() }

        #expect(abs(vm.progress - expected) < 0.0001)
    }
}
