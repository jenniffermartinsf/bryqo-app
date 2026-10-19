import Foundation

/// The learner's decision at a given step: how does the target compare to the middle value?
public enum BinarySearchChoice: Equatable, Sendable {
    case lower    // target is smaller than the middle value → search the left half
    case equal    // target is the middle value → found
    case higher   // target is larger than the middle value → search the right half
}

/// Immutable snapshot of a binary search in progress. Pure value type so the engine stays testable.
public struct BinarySearchState: Equatable, Sendable {
    public let array: [Int]       // must be sorted ascending
    public let target: Int
    public var low: Int
    public var high: Int
    public var stepsTaken: Int
    public var found: Bool
    public var exhausted: Bool    // window collapsed without finding the target

    public init(array: [Int], target: Int) {
        self.array = array
        self.target = target
        self.low = 0
        self.high = array.count - 1
        self.stepsTaken = 0
        self.found = false
        self.exhausted = array.isEmpty
    }

    public var mid: Int? {
        guard low <= high, !array.isEmpty else { return nil }
        return (low + high) / 2
    }

    public var midValue: Int? { mid.map { array[$0] } }
    public var isFinished: Bool { found || exhausted }
}

/// Pure binary-search stepper. The learner drives it by choosing how the target compares to `mid`;
/// the engine validates that choice and narrows the window.
public enum BinarySearchEngine {
    /// The correct comparison at the current middle (what the machine would conclude), or nil if done.
    public static func correctChoice(_ state: BinarySearchState) -> BinarySearchChoice? {
        guard let midValue = state.midValue else { return nil }
        if state.target == midValue { return .equal }
        return state.target < midValue ? .lower : .higher
    }

    /// Applies a (correct) choice, returning the narrowed state. Invalid choices return the state
    /// unchanged — callers decide how to surface a wrong guess.
    public static func apply(_ choice: BinarySearchChoice, to state: BinarySearchState) -> BinarySearchState {
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
