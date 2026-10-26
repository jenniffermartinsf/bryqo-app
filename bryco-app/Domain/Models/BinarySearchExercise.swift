import Foundation

/// Content payload for an interactive binary-search step.
nonisolated struct BinarySearchExercise: Equatable, Hashable {
    let intro: String
    let array: [Int]   // sorted ascending
    let target: Int
}
