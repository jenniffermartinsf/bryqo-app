import Testing
@testable import bryco_app

/// Covers the "Pense como a máquina" (variable trace) flow. Pure `@Observable`, fully isolated.
@Suite("VariableTraceViewModel", .tags(.gamification))
struct VariableTraceViewModelTests {

    private func makeExercise() -> VariableTraceExercise {
        VariableTraceExercise(
            intro: "Acompanhe o contador.",
            codeLines: ["x = 0", "x = x + 1", "x = x * 2"],
            language: .generic,
            steps: [
                VariableTraceStep(highlightedLine: 0, prompt: "Quanto vale x?", variable: "x",
                                  options: ["0", "1"], correctAnswer: "0", explanation: "Inicia em 0."),
                VariableTraceStep(highlightedLine: 1, prompt: "E agora?", variable: "x",
                                  options: ["1", "2"], correctAnswer: "1", explanation: "0 + 1 = 1."),
                VariableTraceStep(highlightedLine: 2, prompt: "E agora?", variable: "x",
                                  options: ["2", "3"], correctAnswer: "2", explanation: "1 * 2 = 2.")
            ]
        )
    }

    @Test("Starts on the first step with an empty state table")
    func startsClean() {
        let vm = VariableTraceViewModel(exercise: makeExercise())
        #expect(vm.stepIndex == 0)
        #expect(vm.revealed.isEmpty)
        #expect(vm.canVerify == false)
        #expect(vm.progress == 0)
    }

    @Test("Selecting enables verify")
    func selectingEnablesVerify() {
        let vm = VariableTraceViewModel(exercise: makeExercise())
        vm.select("0")
        #expect(vm.selectedAnswer == "0")
        #expect(vm.canVerify)
    }

    @Test("A correct prediction counts and reveals the value")
    func correctPrediction() {
        let vm = VariableTraceViewModel(exercise: makeExercise())
        vm.select("0")
        vm.verify()

        #expect(vm.isAnswerCorrect)
        #expect(vm.correctCount == 1)
        #expect(vm.mistakeCount == 0)
        #expect(vm.revealed.map(\.value) == ["0"])
    }

    @Test("A wrong prediction records a mistake but still reveals the correct value")
    func wrongPredictionRevealsCorrect() {
        let vm = VariableTraceViewModel(exercise: makeExercise())
        vm.select("1")   // correct is "0"
        vm.verify()

        #expect(vm.isAnswerCorrect == false)
        #expect(vm.mistakeCount == 1)
        #expect(vm.revealed.map(\.value) == ["0"], "Table teaches the correct value even on a miss")
    }

    @Test("Verifying twice does not double-count")
    func verifyIdempotent() {
        let vm = VariableTraceViewModel(exercise: makeExercise())
        vm.select("1")
        vm.verify()
        vm.verify()
        #expect(vm.mistakeCount == 1)
        #expect(vm.revealed.count == 1)
    }

    @Test("Advancing steps through and completes at the end, accumulating the state table")
    func advanceAccumulatesAndCompletes() {
        let vm = VariableTraceViewModel(exercise: makeExercise())

        vm.select("0"); vm.verify(); vm.advance()
        vm.select("1"); vm.verify(); vm.advance()
        #expect(vm.isComplete == false)
        #expect(vm.revealed.map(\.value) == ["0", "1"])

        vm.select("2"); vm.verify()
        #expect(vm.isLastStep)
        vm.advance()

        #expect(vm.isComplete)
        #expect(vm.correctCount == 3)
        #expect(vm.revealed.map(\.value) == ["0", "1", "2"])
    }
}
