import Foundation

struct LearningUnit: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let lessons: [Lesson]
}

struct Lesson: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let xpReward: Int
    let materialReward: String
    let steps: [LessonStep]
}

struct LessonStep: Identifiable, Equatable {
    let id: String
    let kind: LessonStepKind
    let title: String
    let body: String
    let exercise: Exercise?
}

enum LessonStepKind: Equatable {
    case story
    case concept
    case singleChoice
    case trueFalse
    case ordering
    case summary
}

struct Exercise: Equatable {
    let prompt: String
    let options: [ExerciseOption]
    let correctOptionIds: [String]
    let explanation: String
}

struct ExerciseOption: Identifiable, Equatable {
    let id: String
    let text: String
}

struct OnboardingProfile: Equatable {
    let experience: String
    let goal: String
    let dailyGoalMinutes: Int
}

struct UserProgress: Equatable {
    var completedLessonIds: Set<String> = []
    var xp: Int = 0
    var streakDays: Int = 0
    var earnedMaterials: [String] = []
}
