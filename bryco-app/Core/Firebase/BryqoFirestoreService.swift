import FirebaseFirestore
import Foundation

struct FirestoreUserSnapshot {
    var xp: Int = 0
    var streakDays: Int = 0
    var hearts: Int = 5
    var heartsUpdatedAt: Date = Date()
    var lastActivityDate: Date? = nil
    var completedLessonIds: [String] = []
    var earnedMaterials: [String] = []
    var earnedAchievementIds: [String] = []
    var perfectLessonCount: Int = 0
    var streakFreezeCount: Int = 1
    var dailyXpEarned: Int = 0
    var displayName: String? = nil
    var experience: String? = nil
    var goal: String? = nil
    var dailyGoalMinutes: Int = 20
    var accountCreatedDate: Date = Date()
}

final class BryqoFirestoreService {
    private let db = Firestore.firestore()

    func saveUserData(uid: String, snapshot: FirestoreUserSnapshot) async {
        var data: [String: Any] = [
            "xp": snapshot.xp,
            "streakDays": snapshot.streakDays,
            "hearts": snapshot.hearts,
            "heartsUpdatedAt": Timestamp(date: snapshot.heartsUpdatedAt),
            "completedLessonIds": snapshot.completedLessonIds,
            "earnedMaterials": snapshot.earnedMaterials,
            "earnedAchievementIds": snapshot.earnedAchievementIds,
            "perfectLessonCount": snapshot.perfectLessonCount,
            "streakFreezeCount": snapshot.streakFreezeCount,
            "dailyXpEarned": snapshot.dailyXpEarned,
            "dailyGoalMinutes": snapshot.dailyGoalMinutes,
            "accountCreatedDate": Timestamp(date: snapshot.accountCreatedDate),
            "updatedAt": Timestamp(date: Date())
        ]
        if let d = snapshot.lastActivityDate { data["lastActivityDate"] = Timestamp(date: d) }
        if let v = snapshot.displayName { data["displayName"] = v }
        if let v = snapshot.experience { data["experience"] = v }
        if let v = snapshot.goal { data["goal"] = v }

        try? await db.collection("users").document(uid).setData(data, merge: true)
    }

    func loadUserData(uid: String) async -> FirestoreUserSnapshot? {
        guard let doc = try? await db.collection("users").document(uid).getDocument(),
              doc.exists,
              let data = doc.data() else { return nil }
        return decode(data)
    }

    func saveLessonProgress(uid: String, lessonId: String, mistakes: Int) async {
        try? await db
            .collection("users").document(uid)
            .collection("lessonProgress").document(lessonId)
            .setData(["completedAt": Timestamp(date: Date()), "mistakes": mistakes])
    }

    private func decode(_ data: [String: Any]) -> FirestoreUserSnapshot {
        var s = FirestoreUserSnapshot()
        s.xp = data["xp"] as? Int ?? 0
        s.streakDays = data["streakDays"] as? Int ?? 0
        s.hearts = data["hearts"] as? Int ?? 5
        s.heartsUpdatedAt = (data["heartsUpdatedAt"] as? Timestamp)?.dateValue() ?? Date()
        s.lastActivityDate = (data["lastActivityDate"] as? Timestamp)?.dateValue()
        s.completedLessonIds = data["completedLessonIds"] as? [String] ?? []
        s.earnedMaterials = data["earnedMaterials"] as? [String] ?? []
        s.earnedAchievementIds = data["earnedAchievementIds"] as? [String] ?? []
        s.perfectLessonCount = data["perfectLessonCount"] as? Int ?? 0
        s.streakFreezeCount = data["streakFreezeCount"] as? Int ?? 1
        s.dailyXpEarned = data["dailyXpEarned"] as? Int ?? 0
        s.displayName = data["displayName"] as? String
        s.experience = data["experience"] as? String
        s.goal = data["goal"] as? String
        s.dailyGoalMinutes = data["dailyGoalMinutes"] as? Int ?? 20
        s.accountCreatedDate = (data["accountCreatedDate"] as? Timestamp)?.dateValue() ?? Date()
        return s
    }
}
