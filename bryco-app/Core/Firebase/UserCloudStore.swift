import Foundation

/// What a read of the user's cloud backup actually told us.
///
/// "Could not read" and "there is nothing there" must never be confused: treating an offline
/// read as an empty backup would push empty local progress over the real one.
enum CloudLoadResult {
    /// The backup exists and was read.
    case found(FirestoreUserSnapshot)
    /// The server confirmed there is no backup yet.
    case notFound
    /// We could not find out (offline, timeout, permission…). Nothing should be written.
    case unavailable
}

/// The cloud backup of the user's progress. Abstracted so sync logic can be tested without a network.
protocol UserCloudStore {
    func loadUserData(uid: String) async -> CloudLoadResult
    func saveUserData(uid: String, snapshot: FirestoreUserSnapshot) async
    func saveLessonProgress(uid: String, lessonId: String, mistakes: Int) async
}
