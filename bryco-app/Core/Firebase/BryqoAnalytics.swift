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

    /// Records a non-fatal persistence failure (opening, reading or saving the local store)
    /// in Crashlytics, tagged with the operation that failed.
    nonisolated static func recordPersistenceError(_ error: Error, operation: String) {
        Crashlytics.crashlytics().record(error: error, userInfo: ["operation": operation])
    }

    /// Records a content problem only the team can fix (wrong URL, broken JSON, invalid
    /// lessons, server down after every retry) as a non-fatal error.
    nonisolated static func recordContentIssue(_ issue: ContentIssue) {
        Crashlytics.crashlytics().record(error: NSError(
            domain: "bryqo.content", code: 0,
            userInfo: ["issue": issue.code, NSLocalizedDescriptionKey: issue.details]
        ))
    }

    static func identifyUser(_ uid: String) {
        Crashlytics.crashlytics().setUserID(uid)
    }
}
