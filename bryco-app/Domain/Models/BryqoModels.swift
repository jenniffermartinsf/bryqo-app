import Foundation

struct LearningUnit: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let lessons: [Lesson]
}

struct Lesson: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let xpReward: Int
    let materialReward: String
    let steps: [LessonStep]
}

struct LessonStep: Identifiable, Equatable, Hashable {
    let id: String
    let kind: LessonStepKind
    let title: String
    let body: String
    let exercise: Exercise?
    let variableTrace: VariableTraceExercise?
    let binarySearch: BinarySearchExercise?

    init(id: String, kind: LessonStepKind, title: String, body: String,
         exercise: Exercise? = nil, variableTrace: VariableTraceExercise? = nil,
         binarySearch: BinarySearchExercise? = nil) {
        self.id = id
        self.kind = kind
        self.title = title
        self.body = body
        self.exercise = exercise
        self.variableTrace = variableTrace
        self.binarySearch = binarySearch
    }
}

enum LessonStepKind: Equatable, Hashable {
    case story
    case concept
    case singleChoice
    case trueFalse
    case ordering
    case codeCompletion
    case variableTrace   // "Pense como a máquina" — predict variable state line by line
    case binarySearch    // interactive binary-search playground
    case summary
}

// MARK: - Variable Trace ("think like the machine")

/// One prediction inside a variable-trace exercise: after a given line runs, what does a
/// variable hold?
struct VariableTraceStep: Equatable, Hashable {
    let highlightedLine: Int   // 0-based index into `codeLines` to spotlight
    let prompt: String
    let variable: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
}

/// A pseudocode snippet the learner "executes" in their head, predicting the running state.
struct VariableTraceExercise: Equatable, Hashable {
    let intro: String
    let codeLines: [String]
    let language: CodeLanguage
    let steps: [VariableTraceStep]
}

struct CodeSnippet: Equatable, Hashable {
    let code: String
    let language: CodeLanguage
}

enum CodeLanguage: String, Equatable, Hashable {
    case python = "Python"
    case swift = "Swift"
    case javascript = "JavaScript"
    case generic = "Código"
}

struct Exercise: Equatable, Hashable {
    let prompt: String
    let options: [ExerciseOption]
    let correctOptionIds: [String]
    let explanation: String
    let codeSnippet: CodeSnippet?

    init(prompt: String, options: [ExerciseOption], correctOptionIds: [String], explanation: String, codeSnippet: CodeSnippet? = nil) {
        self.prompt = prompt
        self.options = options
        self.correctOptionIds = correctOptionIds
        self.explanation = explanation
        self.codeSnippet = codeSnippet
    }
}

struct ExerciseOption: Identifiable, Equatable, Hashable {
    let id: String
    let text: String
}

struct OnboardingProfile: Equatable {
    let displayName: String
    let experience: String
    let goal: String
    let dailyGoalMinutes: Int
    let accountCreatedDate: Date
}

struct UserProgress: Equatable {
    var completedLessonIds: Set<String> = []
    var xp: Int = 0
    var streakDays: Int = 0
    var earnedMaterials: [String] = []
    // Gamification
    var hearts: Int = 5
    var lastActivityDate: Date? = nil
    var earnedAchievementIds: Set<String> = []
    var perfectLessonCount: Int = 0
    // Streak protection — used automatically when a day is missed
    var streakFreezeCount: Int = 1
    // Daily goal tracking — both reset at midnight
    var dailyMinutesStudied: Int = 0
    var dailyXpEarned: Int = 0
    // Hearts regeneration baseline — updated when a heart is lost
    var heartsUpdatedAt: Date = Date()
    // Spaced repetition (SM-2) — one entry per reviewed lesson, keyed by lessonId
    var reviewStates: [String: ReviewState] = [:]
}

// MARK: - Achievement

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let rarity: Rarity

    enum Rarity { case common, rare, epic }
}
