import Foundation

/// The learner's decision at a given step: how does the target compare to the middle value?
enum BinarySearchChoice: Equatable {
    case lower    // target is smaller than the middle value → search the left half
    case equal    // target is the middle value → found
    case higher   // target is larger than the middle value → search the right half
}

/// Immutable snapshot of a binary search in progress. Pure value type so the engine stays testable.
struct BinarySearchState: Equatable {
    let array: [Int]       // must be sorted ascending
    let target: Int
    var low: Int
    var high: Int
    var stepsTaken: Int
    var found: Bool
    var exhausted: Bool    // window collapsed without finding the target

    init(array: [Int], target: Int) {
        self.array = array
        self.target = target
        self.low = 0
        self.high = array.count - 1
        self.stepsTaken = 0
        self.found = false
        self.exhausted = array.isEmpty
    }

    var mid: Int? {
        guard low <= high, !array.isEmpty else { return nil }
        return (low + high) / 2
    }

    var midValue: Int? { mid.map { array[$0] } }
    var isFinished: Bool { found || exhausted }
}

/// Pure binary-search stepper. The learner drives it by choosing how the target compares to `mid`;
/// the engine validates that choice and narrows the window.
enum BinarySearchEngine {
    /// The correct comparison at the current middle (what the machine would conclude), or nil if done.
    static func correctChoice(_ state: BinarySearchState) -> BinarySearchChoice? {
        guard let midValue = state.midValue else { return nil }
        if state.target == midValue { return .equal }
        return state.target < midValue ? .lower : .higher
    }

    /// Applies a (correct) choice, returning the narrowed state. Invalid choices return the state
    /// unchanged — callers decide how to surface a wrong guess.
    static func apply(_ choice: BinarySearchChoice, to state: BinarySearchState) -> BinarySearchState {
        guard let mid = state.mid else { return state }
        var next = state
        next.stepsTaken += 1
        switch choice {
        case .equal:
            next.found = true
        case .lower:
            next.high = mid - 1
        case .higher:
            next.low = mid + 1
        }
        if !next.found && next.low > next.high { next.exhausted = true }
        return next
    }
}

/// Content payload for an interactive binary-search step.
struct BinarySearchExercise: Equatable, Hashable {
    let intro: String
    let array: [Int]   // sorted ascending
    let target: Int
}
