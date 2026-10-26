import Foundation

// Wire format of the remote lesson catalog. These types mirror the JSON, not the app:
// `toDomain()` maps them into the app's models and drops anything that would break a lesson.
// Keeping the two apart means the API can evolve without touching the views.

nonisolated struct ContentCatalogDTO: Codable, Equatable, Sendable {
    /// Bumped whenever the content changes, so an older cached catalog never replaces a newer one.
    let version: Int
    let units: [UnitDTO]
}

nonisolated struct UnitDTO: Codable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let lessons: [LessonDTO]
}

nonisolated struct LessonDTO: Codable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let xpReward: Int
    let materialReward: String
    let steps: [StepDTO]
}

nonisolated struct StepDTO: Codable, Equatable, Sendable {
    let id: String
    /// Kept as a string: an unknown kind sent by a newer server is skipped instead of failing
    /// the whole decode.
    let kind: String
    let title: String
    let body: String
    let exercise: ExerciseDTO?
    let variableTrace: VariableTraceDTO?
    let binarySearch: BinarySearchDTO?
}

nonisolated struct ExerciseDTO: Codable, Equatable, Sendable {
    let prompt: String
    let options: [OptionDTO]
    let correctOptionIds: [String]
    let explanation: String
    let codeSnippet: CodeSnippetDTO?
}

nonisolated struct OptionDTO: Codable, Equatable, Sendable {
    let id: String
    let text: String
}

nonisolated struct CodeSnippetDTO: Codable, Equatable, Sendable {
    let code: String
    let language: String
}

nonisolated struct VariableTraceDTO: Codable, Equatable, Sendable {
    let intro: String
    let codeLines: [String]
    let language: String
    let steps: [VariableTraceStepDTO]
}

nonisolated struct VariableTraceStepDTO: Codable, Equatable, Sendable {
    let highlightedLine: Int
    let prompt: String
    let variable: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
}

nonisolated struct BinarySearchDTO: Codable, Equatable, Sendable {
    let intro: String
    let array: [Int]
    let target: Int
}
