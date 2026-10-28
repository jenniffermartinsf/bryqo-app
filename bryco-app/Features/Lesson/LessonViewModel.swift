import Foundation
import Observation

@Observable
final class LessonViewModel {
    let lesson: Lesson

    private(set) var stepIndex: Int = 0
    private(set) var selectedOptionIds: [String] = []
    private(set) var hasAnswered: Bool = false
    private(set) var hearts: Int
    private(set) var mistakeCount: Int = 0
    private(set) var xpEarned: Int = 0
    private(set) var correctCount: Int = 0
    private(set) var isComplete: Bool = false
    private(set) var shakeTrigger: Int = 0
    private(set) var xpFloatTrigger: Int = 0

    /// Charges the app for hearts lost in this lesson, with how many were lost at once.
    @ObservationIgnored private let loseHearts: (Int) -> Void

    var currentStep: LessonStep {
        lesson.steps[stepIndex]
    }

    var isLastStep: Bool {
        stepIndex == lesson.steps.count - 1
    }

    var progress: Double {
        guard !lesson.steps.isEmpty else { return 0 }
        return Double(stepIndex) / Double(lesson.steps.count)
    }

    var isAnswerCorrect: Bool {
        guard let exercise = currentStep.exercise else { return true }
        return selectedOptionIds == exercise.correctOptionIds
    }

    var canVerify: Bool {
        guard currentStep.exercise != nil else { return true }
        return !selectedOptionIds.isEmpty
    }

    /// Out of hearts with nothing left to read: the lesson stops here. While the feedback of
    /// the answer that cost the last heart is on screen, the learner can still read it.
    var isOutOfHearts: Bool {
        hearts == 0 && !hasAnswered && !isComplete
    }

    init(lesson: Lesson, initialHearts: Int, loseHearts: @escaping (Int) -> Void = { _ in }) {
        self.lesson = lesson
        self.hearts = initialHearts
        self.loseHearts = loseHearts
    }

    func selectOption(_ option: ExerciseOption) {
        guard !hasAnswered, currentStep.exercise != nil else { return }
        switch currentStep.kind {
        case .ordering:
            if selectedOptionIds.contains(option.id) {
                selectedOptionIds.removeAll { $0 == option.id }
            } else {
                selectedOptionIds.append(option.id)
            }
        default:
            selectedOptionIds = [option.id]
        }
    }

    func verify() {
        guard currentStep.exercise != nil, !hasAnswered else { return }
        hasAnswered = true
        if !isAnswerCorrect {
            spendHearts(1)
            mistakeCount += 1
            shakeTrigger += 1
        } else {
            xpEarned += 10
            correctCount += 1
            xpFloatTrigger += 1
        }
        BryqoAnalytics.exerciseAnswered(
            lessonId: lesson.id,
            stepId: currentStep.id,
            correct: isAnswerCorrect
        )
    }

    func advance() {
        if isLastStep {
            isComplete = true
            return
        }
        stepIndex += 1
        selectedOptionIds = []
        hasAnswered = false
    }

    /// Folds the outcome of a self-contained variable-trace step into the lesson totals,
    /// then advances. Each wrong prediction costs a heart, like a normal exercise.
    func applyTraceResult(mistakes: Int, correct: Int) {
        mistakeCount += mistakes
        correctCount += correct
        xpEarned += correct * 10
        spendHearts(mistakes)
        advance()
    }

    /// Takes up to `count` hearts and reports the ones actually lost, never below zero.
    private func spendHearts(_ count: Int) {
        let lost = min(count, hearts)
        guard lost > 0 else { return }
        hearts -= lost
        loseHearts(lost)
    }

    var isVariableTraceStep: Bool { currentStep.variableTrace != nil }
}
