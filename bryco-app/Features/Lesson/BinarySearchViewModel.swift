import Foundation
import Observation

/// Drives the interactive binary-search playground: the learner repeatedly decides how the target
/// compares to the middle element, watching half of the array get discarded each step. Pure
/// `@Observable` so the whole interaction is unit-testable.
@Observable
final class BinarySearchViewModel {
    let exercise: BinarySearchExercise

    private(set) var state: BinarySearchState
    private(set) var mistakeCount: Int = 0
    private(set) var shakeTrigger: Int = 0
    private(set) var lastWasWrong: Bool = false
    /// Indices already ruled out — the view greys these out.
    private(set) var discarded: Set<Int> = []

    init(exercise: BinarySearchExercise) {
        self.exercise = exercise
        self.state = BinarySearchState(array: exercise.array, target: exercise.target)
    }

    var isFinished: Bool { state.isFinished }
    var found: Bool { state.found }
    var stepsTaken: Int { state.stepsTaken }
    /// Worst-case comparisons a naive linear scan would need — the "why log n matters" payoff.
    var linearWorstCase: Int { exercise.array.count }

    /// Applies the learner's comparison. A correct choice narrows the window and discards a half;
    /// a wrong one costs a mistake and lets them try again.
    func choose(_ choice: BinarySearchChoice) {
        guard !state.isFinished else { return }
        guard let mid = state.mid, choice == BinarySearchEngine.correctChoice(state) else {
            mistakeCount += 1
            shakeTrigger += 1
            lastWasWrong = true
            return
        }

        lastWasWrong = false
        switch choice {
        case .lower:  if state.high >= mid { for i in mid...state.high { discarded.insert(i) } }
        case .higher: if mid >= state.low { for i in state.low...mid { discarded.insert(i) } }
        case .equal:  break
        }
        state = BinarySearchEngine.apply(choice, to: state)
    }
}
