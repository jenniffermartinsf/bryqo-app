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
}

enum LessonStepKind: Equatable, Hashable {
    case story
    case concept
    case singleChoice
    case trueFalse
    case ordering
    case codeCompletion
    case summary
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
    // Daily goal tracking — resets at midnight each day
    var dailyMinutesStudied: Int = 0
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
