import Foundation
import Observation

/// A variable's value revealed in the running state table.
struct RevealedValue: Identifiable, Equatable {
    let id = UUID()
    let variable: String
    let value: String
}

/// Drives a "Pense como a máquina" exercise: the learner predicts a variable's value after each
/// spotlighted line, and the correct value is added to a running state table. Pure `@Observable`
/// with no dependencies, so it's fully unit-testable.
@Observable
final class VariableTraceViewModel {
    let exercise: VariableTraceExercise

    private(set) var stepIndex: Int = 0
    private(set) var selectedAnswer: String? = nil
    private(set) var hasAnswered: Bool = false
    private(set) var mistakeCount: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var isComplete: Bool = false
    private(set) var shakeTrigger: Int = 0
    /// Correct values accumulated so far, shown as the running "machine state".
    private(set) var revealed: [RevealedValue] = []

    init(exercise: VariableTraceExercise) {
        self.exercise = exercise
    }

    var currentStep: VariableTraceStep { exercise.steps[stepIndex] }
    var isLastStep: Bool { stepIndex == exercise.steps.count - 1 }
    var isAnswerCorrect: Bool { selectedAnswer == currentStep.correctAnswer }
    var canVerify: Bool { selectedAnswer != nil }

    var progress: Double {
        guard !exercise.steps.isEmpty else { return 0 }
        return Double(stepIndex) / Double(exercise.steps.count)
    }

    func select(_ option: String) {
        guard !hasAnswered else { return }
        selectedAnswer = option
    }

    func verify() {
        guard !hasAnswered, selectedAnswer != nil else { return }
        hasAnswered = true
        if isAnswerCorrect {
            correctCount += 1
        } else {
            mistakeCount += 1
            shakeTrigger += 1
        }
        // The state table always shows the *correct* value, teaching the right mental model
        // even when the learner missed it.
        revealed.append(RevealedValue(variable: currentStep.variable, value: currentStep.correctAnswer))
    }

    func advance() {
        if isLastStep {
            isComplete = true
            return
        }
        stepIndex += 1
        selectedAnswer = nil
        hasAnswered = false
    }
}
