import Foundation
import Observation

@Observable
final class BryqoAppState {
    var profile: OnboardingProfile?
    var progress = UserProgress()

    var hasCompletedOnboarding: Bool {
        profile != nil
    }

    var completedLessonCount: Int {
        progress.completedLessonIds.count
    }

    func completeOnboarding(experience: String, goal: String, dailyGoalMinutes: Int) {
        profile = OnboardingProfile(
            experience: experience,
            goal: goal,
            dailyGoalMinutes: dailyGoalMinutes
        )
    }

    func isLessonCompleted(_ lesson: Lesson) -> Bool {
        progress.completedLessonIds.contains(lesson.id)
    }

    func canStartLesson(_ lesson: Lesson, in unit: LearningUnit) -> Bool {
        guard let index = unit.lessons.firstIndex(of: lesson) else {
            return false
        }

        if index == 0 {
            return true
        }

        let previousLesson = unit.lessons[index - 1]
        return isLessonCompleted(previousLesson)
    }

    func completeLesson(_ lesson: Lesson) {
        guard !isLessonCompleted(lesson) else {
            return
        }

        progress.completedLessonIds.insert(lesson.id)
        progress.xp += lesson.xpReward
        progress.streakDays = max(progress.streakDays, 1)
        progress.earnedMaterials.append(lesson.materialReward)
    }
}
