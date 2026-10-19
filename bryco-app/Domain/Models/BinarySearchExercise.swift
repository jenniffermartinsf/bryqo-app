import Foundation

/// Content payload for an interactive binary-search step.
struct BinarySearchExercise: Equatable, Hashable {
    let intro: String
    let array: [Int]   // sorted ascending
    let target: Int
}
