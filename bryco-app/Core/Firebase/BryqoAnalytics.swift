import FirebaseAnalytics
import FirebaseCrashlytics

enum BryqoAnalytics {

    static func lessonStarted(lessonId: String) {
        Analytics.logEvent("lesson_start", parameters: [
            "lesson_id": lessonId
        ])
    }

    static func lessonCompleted(lessonId: String, xpEarned: Int, perfect: Bool) {
        Analytics.logEvent("lesson_complete", parameters: [
            "lesson_id": lessonId,
            "xp_earned": xpEarned,
            "perfect": perfect ? 1 : 0
        ])
    }

    static func exerciseAnswered(lessonId: String, stepId: String, correct: Bool) {
        Analytics.logEvent("exercise_answered", parameters: [
            "lesson_id": lessonId,
            "step_id": stepId,
            "correct": correct ? 1 : 0
        ])
    }

    static func streakMilestone(days: Int) {
        Analytics.logEvent("streak_milestone", parameters: [
            "days": days
        ])
    }

    static func paywallViewed() {
        Analytics.logEvent("paywall_view", parameters: [:])
    }

    static func identifyUser(_ uid: String) {
        Crashlytics.crashlytics().setUserID(uid)
    }
}
