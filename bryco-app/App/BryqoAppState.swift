import BryqoDomain
import SwiftUI
import Observation
import SwiftData
import WidgetKit

@Observable
final class BryqoAppState {
    /// Shared with SwiftUI (`.modelContainer`) so `@Query` views read the same store.
    @ObservationIgnored let modelContainer: ModelContainer
    @ObservationIgnored private let modelContext: ModelContext
    /// Bumped whenever review rows change, so views reading review counts re-render.
    /// SwiftData fetches are not observed by the Observation framework on their own.
    private var reviewsRevision = 0
    @ObservationIgnored private var persistedState: PersistedUserState
    @ObservationIgnored let notificationManager = BryqoNotificationManager()
    @ObservationIgnored let authManager = BryqoAuthManager()
    /// Lesson catalog: bundled content, replaced by a newer remote catalog when one arrives.
    let content: ContentRepository
    @ObservationIgnored private let cloudStore: any UserCloudStore
    /// Prevents overlapping syncs when launch and "back to foreground" fire close together.
    @ObservationIgnored private var isSyncing = false
    /// The cloud account this session has reconciled with. Writes go to the cloud only after
    /// that: until then local progress may be empty (a reinstall opened offline) and pushing it
    /// would overwrite the real backup. Everything is still saved locally in the meantime.
    @ObservationIgnored private var reconciledCloudUID: String?
    /// The signed-in account; injectable so tests can act as a signed-in user.
    @ObservationIgnored private var signedInUID: () -> String? = { nil }

    /// Where local saves are mirrored, or `nil` while the cloud hasn't been reconciled.
    private var cloudUIDForWrites: String? {
        guard let uid = signedInUID(), uid == reconciledCloudUID else { return nil }
        return uid
    }

    var profile: OnboardingProfile?
    var progress = UserProgress()

    var isLightMode: Bool = true {
        didSet { UserDefaults.standard.set(isLightMode, forKey: "bryqo.isLightMode") }
    }
    var notificationsEnabled: Bool = false
    /// Whether progress is reaching disk; drives the warning banner.
    private(set) var persistenceHealth: PersistenceHealth = .healthy
    @ObservationIgnored private let reportPersistenceError: (Error, String) -> Void
    var pendingStreakMilestone: Int? = nil

    /// Decoded once, off the main thread, so the profile never decodes a photo while rendering.
    private(set) var avatarImage: UIImage?
    @ObservationIgnored private let avatarStore: AvatarStore

    /// - Parameters:
    ///   - inMemory: when `true`, uses a throwaway in-memory store instead of the on-disk one.
    ///     Kept out of production call sites (defaults to `false`) and used by tests so each case
    ///     starts from a clean, isolated state.
    ///   - openStore: opens the on-disk store. Injected so tests can simulate a store that fails
    ///     to open (for example, a migration error).
    ///   - reportPersistenceError: where persistence failures are reported (Crashlytics by default).
    init(
        inMemory: Bool = false,
        openStore: (() throws -> ModelContainer)? = nil,
        reportPersistenceError: @escaping (Error, String) -> Void = BryqoAnalytics.recordPersistenceError,
        cloudStore: (any UserCloudStore)? = nil,
        signedInUID: (() -> String?)? = nil,
        content: ContentRepository? = nil,
        avatarStore: AvatarStore? = nil
    ) {
        self.avatarStore = avatarStore ?? (inMemory
            ? AvatarStore(fileURL: FileManager.default.temporaryDirectory
                .appendingPathComponent("bryqo-avatar-\(UUID().uuidString).jpg"))
            : AvatarStore())
        // Tests (inMemory) get a throwaway cache so they never read content saved by the app.
        self.content = content ?? (inMemory
            ? ContentRepository(cache: ContentCache(directory: FileManager.default.temporaryDirectory
                .appendingPathComponent("bryqo-content-\(UUID().uuidString)")))
            : ContentRepository())
        self.reportPersistenceError = reportPersistenceError
        self.cloudStore = cloudStore ?? BryqoFirestoreService()
        let schema = Schema(versionedSchema: BryqoSchemaV6.self)
        let makeInMemoryContainer = {
            try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            )
        }
        let openOnDiskStore = openStore ?? {
            try ModelContainer(
                for: schema,
                migrationPlan: BryqoMigrationPlan.self,
                configurations: ModelConfiguration(schema: schema)
            )
        }

        if inMemory {
            modelContainer = makeInMemoryContainer()
        } else {
            do {
                modelContainer = try openOnDiskStore()
            } catch {
                // Keep the app usable, but never silently: report it and warn the user that
                // nothing will survive closing the app.
                reportPersistenceError(error, "open_store")
                modelContainer = makeInMemoryContainer()
                persistenceHealth = .temporaryStorage
            }
        }

        // The main context is the one `@Query` uses, so app writes show up in views immediately.
        modelContext = modelContainer.mainContext

        var results: [PersistedUserState] = []
        do {
            results = try modelContext.fetch(FetchDescriptor<PersistedUserState>())
        } catch {
            reportPersistenceError(error, "fetch_user_state")
        }
        if let existing = results.first {
            persistedState = existing
        } else {
            let newState = PersistedUserState()
            modelContext.insert(newState)
            persistedState = newState
            saveContext(operation: "create_user_state")
        }

        progress = UserProgress(
            completedLessonIds: Set(persistedState.completedLessonIds),
            xp: persistedState.xp,
            streakDays: persistedState.streakDays,
            earnedMaterials: persistedState.earnedMaterials,
            hearts: persistedState.hearts,
            lastActivityDate: persistedState.lastActivityDate,
            earnedAchievementIds: Set(persistedState.earnedAchievementIds),
            perfectLessonCount: persistedState.perfectLessonCount,
            streakFreezeCount: persistedState.streakFreezeCount,
            dailyMinutesStudied: persistedState.dailyMinutesStudied,
            dailyXpEarned: persistedState.dailyXpEarned,
            heartsUpdatedAt: persistedState.heartsUpdatedAt
        )

        if let last = progress.lastActivityDate,
           !Calendar.current.isDate(last, inSameDayAs: Date()) {
            progress.dailyMinutesStudied = 0
            progress.dailyXpEarned = 0
            persistedState.dailyMinutesStudied = 0
            persistedState.dailyXpEarned = 0
            saveContext(operation: "reset_daily_progress")
        }

        if let name = persistedState.displayName,
           let experience = persistedState.experience,
           let goal = persistedState.goal {
            profile = OnboardingProfile(
                displayName: name,
                experience: experience,
                goal: goal,
                dailyGoalMinutes: persistedState.dailyGoalMinutes,
                accountCreatedDate: persistedState.accountCreatedDate
            )
        }

        if let saved = UserDefaults.standard.object(forKey: "bryqo.isLightMode") as? Bool {
            isLightMode = saved
        }
        notificationsEnabled = UserDefaults.standard.bool(forKey: "bryqo.notifications.enabled")

        applyStreakDecay()
        applyHeartRegeneration()

        // Set last: the default captures self, which needs every stored property initialized.
        let authManager = self.authManager
        self.signedInUID = signedInUID ?? { authManager.currentUID }
    }

    // MARK: - Streak Decay

    /// Consume a streak freeze (or reset) when the user missed more than one day.
    /// Called on init and foreground so decay applies even without completing a lesson.
    func applyStreakDecay() {
        guard progress.streakDays > 0, let last = progress.lastActivityDate else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        guard last < yesterday, !Calendar.current.isDate(last, inSameDayAs: yesterday) else { return }
        if progress.streakFreezeCount > 0 {
            progress.streakFreezeCount -= 1
            progress.lastActivityDate = yesterday  // freeze covers the missed day
        } else {
            progress.streakDays = 0
        }
        save()
    }

    // MARK: - Hearts Regeneration

    static let heartsMax = 5
    static let heartRegenInterval: TimeInterval = 30 * 60  // 30 minutes

    /// +1 heart per `heartRegenInterval`. Advances `heartsUpdatedAt` by the time consumed.
    func applyHeartRegeneration() {
        guard progress.hearts < BryqoAppState.heartsMax else { return }
        let elapsed = Date().timeIntervalSince(progress.heartsUpdatedAt)
        let regenerated = Int(elapsed / BryqoAppState.heartRegenInterval)
        guard regenerated > 0 else { return }
        let gained = min(regenerated, BryqoAppState.heartsMax - progress.hearts)
        progress.hearts += gained
        progress.heartsUpdatedAt = progress.heartsUpdatedAt
            .addingTimeInterval(Double(gained) * BryqoAppState.heartRegenInterval)
        save()
    }

    /// Date when the next heart will finish regenerating. Nil if hearts are full.
    var nextHeartAt: Date? {
        guard progress.hearts < BryqoAppState.heartsMax else { return nil }
        return progress.heartsUpdatedAt.addingTimeInterval(BryqoAppState.heartRegenInterval)
    }

    // MARK: - Firestore sync

    /// Signs in if needed and reconciles local progress with the cloud backup. Called on launch
    /// and every time the app comes back to the foreground, so a launch without internet
    /// catches up as soon as the connection returns.
    // MARK: - Avatar

    func loadAvatar() async {
        guard avatarImage == nil, let data = await avatarStore.load() else { return }
        avatarImage = await UIImage(data: data)?.byPreparingForDisplay()
    }

    /// Shrinks and stores a picked photo. The work happens off the main actor; only the
    /// final assignment runs here. Throws `CancellationError` if a newer photo replaced it.
    func setAvatar(_ photo: Data) async throws {
        let avatar = try await avatarStore.save(photo)
        let image = await UIImage(data: avatar)?.byPreparingForDisplay()
        try Task.checkCancellation()
        avatarImage = image
    }

    func syncWithCloud() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        await authManager.signInAnonymouslyIfNeeded()
        guard let uid = signedInUID() else { return }
        await sync(uid: uid)
    }

    /// `syncWithCloud` without the Firebase Auth sign-in step.
    func syncWithCloudForTesting() async {
        guard let uid = signedInUID() else { return }
        await sync(uid: uid)
    }

    /// Local progress is the source of truth; the cloud is a backup. Separate from
    /// `syncWithCloud` so tests can run it without Firebase Auth.
    func sync(uid: String) async {
        switch await cloudStore.loadUserData(uid: uid) {
        case .found(let remote):
            reconciledCloudUID = uid
            mergeRemote(remote)   // saves, which now also pushes the merged result
            await cloudStore.saveUserData(uid: uid, snapshot: buildSnapshot())
        case .notFound:
            // Confirmed by the server: first backup for this account.
            reconciledCloudUID = uid
            await cloudStore.saveUserData(uid: uid, snapshot: buildSnapshot())
        case .unavailable:
            // Offline or unknown. Writing now could overwrite a real backup with empty local
            // progress (e.g. a reinstall opened without internet), so wait for the next sync.
            break
        }
    }

    // Non-private so tests can exercise the local↔remote merge in isolation.
    func mergeRemote(_ remote: FirestoreUserSnapshot) {
        progress.xp = max(progress.xp, remote.xp)
        progress.streakDays = max(progress.streakDays, remote.streakDays)
        progress.hearts = remote.hearts
        progress.heartsUpdatedAt = remote.heartsUpdatedAt
        progress.completedLessonIds.formUnion(remote.completedLessonIds)

        let localSet = Set(progress.earnedMaterials)
        for m in remote.earnedMaterials where !localSet.contains(m) {
            progress.earnedMaterials.append(m)
        }
        progress.earnedAchievementIds.formUnion(remote.earnedAchievementIds)
        progress.perfectLessonCount = max(progress.perfectLessonCount, remote.perfectLessonCount)
        progress.streakFreezeCount = max(progress.streakFreezeCount, remote.streakFreezeCount)

        if let remoteDate = remote.lastActivityDate {
            if let localDate = progress.lastActivityDate {
                if remoteDate > localDate { progress.lastActivityDate = remoteDate }
            } else {
                progress.lastActivityDate = remoteDate
            }
        }

        let today = Calendar.current.startOfDay(for: Date())
        if let remoteDate = remote.lastActivityDate,
           Calendar.current.isDate(remoteDate, inSameDayAs: today) {
            progress.dailyXpEarned = max(progress.dailyXpEarned, remote.dailyXpEarned)
        }

        if profile == nil,
           let name = remote.displayName,
           let exp = remote.experience,
           let g = remote.goal {
            profile = OnboardingProfile(
                displayName: name,
                experience: exp,
                goal: g,
                dailyGoalMinutes: remote.dailyGoalMinutes,
                accountCreatedDate: remote.accountCreatedDate
            )
        }

        save()
        applyHeartRegeneration()
    }

    private func buildSnapshot() -> FirestoreUserSnapshot {
        var s = FirestoreUserSnapshot()
        s.xp = progress.xp
        s.streakDays = progress.streakDays
        s.hearts = progress.hearts
        s.heartsUpdatedAt = progress.heartsUpdatedAt
        s.lastActivityDate = progress.lastActivityDate
        s.completedLessonIds = Array(progress.completedLessonIds)
        s.earnedMaterials = progress.earnedMaterials
        s.earnedAchievementIds = Array(progress.earnedAchievementIds)
        s.perfectLessonCount = progress.perfectLessonCount
        s.streakFreezeCount = progress.streakFreezeCount
        s.dailyMinutesStudied = progress.dailyMinutesStudied
        s.dailyXpEarned = progress.dailyXpEarned
        s.displayName = profile?.displayName
        s.experience = profile?.experience
        s.goal = profile?.goal
        s.dailyGoalMinutes = profile?.dailyGoalMinutes ?? 20
        s.accountCreatedDate = profile?.accountCreatedDate ?? Date()
        return s
    }

    private func save() {
        persistedState.completedLessonIds = Array(progress.completedLessonIds)
        persistedState.xp = progress.xp
        persistedState.streakDays = progress.streakDays
        persistedState.earnedMaterials = progress.earnedMaterials
        persistedState.hearts = progress.hearts
        persistedState.heartsUpdatedAt = progress.heartsUpdatedAt
        persistedState.lastActivityDate = progress.lastActivityDate
        persistedState.earnedAchievementIds = Array(progress.earnedAchievementIds)
        persistedState.perfectLessonCount = progress.perfectLessonCount
        persistedState.streakFreezeCount = progress.streakFreezeCount
        persistedState.dailyMinutesStudied = progress.dailyMinutesStudied
        persistedState.dailyXpEarned = progress.dailyXpEarned
        persistedState.displayName = profile?.displayName
        persistedState.experience = profile?.experience
        persistedState.goal = profile?.goal
        persistedState.dailyGoalMinutes = profile?.dailyGoalMinutes ?? 20
        persistedState.accountCreatedDate = profile?.accountCreatedDate ?? Date()
        saveContext(operation: "save_progress")

        mirrorToWidget()

        if let uid = cloudUIDForWrites {
            let snapshot = buildSnapshot()
            Task { await cloudStore.saveUserData(uid: uid, snapshot: snapshot) }
        }
    }

    /// Writes pending changes to disk, reporting failures instead of swallowing them.
    /// A temporary in-memory store keeps its warning: a successful save there still loses data.
    private func saveContext(operation: String) {
        do {
            try modelContext.save()
            if persistenceHealth == .saveFailed {
                persistenceHealth = .healthy
            }
        } catch {
            reportPersistenceError(error, operation)
            if persistenceHealth == .healthy {
                persistenceHealth = .saveFailed
            }
        }
    }

    /// Pushes a small snapshot to the App Group so the widget can render streak/goal without
    /// touching SwiftData or Firestore, then asks WidgetKit to refresh.
    private func mirrorToWidget() {
        BryqoSharedStore.write(
            BryqoWidgetSnapshot(
                streakDays: progress.streakDays,
                dailyXpEarned: progress.dailyXpEarned,
                dailyGoalXp: dailyGoalXp,
                updatedAt: Date()
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Static Definitions

    static let allAchievements: [Achievement] = [
        Achievement(id: "first_lesson",  title: "Primeiro Bloco",   description: "Conclua sua primeira lição.",             icon: "checkmark.seal.fill", rarity: .common),
        Achievement(id: "streak_3",      title: "Em Ritmo",         description: "3 dias consecutivos de estudo.",          icon: "bolt.fill",           rarity: .common),
        Achievement(id: "streak_7",      title: "Semana Sólida",    description: "7 dias consecutivos de estudo.",          icon: "flame.fill",          rarity: .rare),
        Achievement(id: "lessons_5",     title: "Construtor",       description: "Conclua 5 lições no total.",              icon: "hammer.fill",         rarity: .common),
        Achievement(id: "lessons_10",    title: "Maratonista",      description: "Conclua 10 lições no total.",             icon: "figure.run",          rarity: .rare),
        Achievement(id: "xp_100",        title: "Centenário",       description: "Acumule 100 pontos de XP.",               icon: "star.fill",           rarity: .common),
        Achievement(id: "xp_500",        title: "Mestre da XP",     description: "Acumule 500 pontos de XP.",               icon: "star.circle.fill",    rarity: .rare),
        Achievement(id: "perfect",       title: "Impecável",        description: "Conclua uma lição sem nenhum erro.",      icon: "crown.fill",          rarity: .epic),
        Achievement(id: "materials_5",   title: "Mochila Cheia",    description: "Colecione 5 materiais no total.",         icon: "backpack.fill",       rarity: .common),
        Achievement(id: "level_3",       title: "Nível 3",          description: "Alcance o nível 3.",                      icon: "rosette",             rarity: .rare),
    ]

    static let levelThresholds: [Int] = [0, 100, 250, 500, 1000, 2000, 3500, 5000, 7500, 10000]

    // MARK: - Computed Properties

    var hasCompletedOnboarding: Bool { profile != nil }
    var completedLessonCount: Int { progress.completedLessonIds.count }
    var preferredColorScheme: ColorScheme { isLightMode ? .light : .dark }

    var currentLevel: Int {
        for (i, threshold) in BryqoAppState.levelThresholds.enumerated().reversed() {
            if progress.xp >= threshold { return i + 1 }
        }
        return 1
    }

    var levelName: String {
        switch currentLevel {
        case 1: return "Aprendiz"
        case 2: return "Estudante"
        case 3: return "Desenvolvedor"
        case 4: return "Arquiteto"
        default: return "Engenheiro"
        }
    }

    var xpForCurrentLevel: Int { BryqoAppState.levelThresholds[max(0, currentLevel - 1)] }

    var xpForNextLevel: Int {
        let t = BryqoAppState.levelThresholds
        let l = currentLevel
        guard l < t.count else { return t.last ?? 10000 }
        return t[l]
    }

    var xpProgressInLevel: Double {
        let current = Double(progress.xp - xpForCurrentLevel)
        let total = Double(xpForNextLevel - xpForCurrentLevel)
        guard total > 0 else { return 1.0 }
        return min(1.0, current / total)
    }

    var isStreakAtRisk: Bool {
        guard progress.streakDays > 0, let last = progress.lastActivityDate else { return false }
        return !Calendar.current.isDate(last, inSameDayAs: Calendar.current.startOfDay(for: Date()))
    }

    /// Single source of truth for XP goal per onboarding tier (minutes → XP).
    static func xpGoal(for minutes: Int) -> Int {
        switch minutes {
        case 5:  return 15   // Casual  — 1 lesson/day
        case 10: return 30   // Regular — 2 lessons/day
        case 15: return 50   // Sério   — 3 lessons/day
        default: return 75   // Intenso — 5 lessons/day
        }
    }

    var dailyGoalXp: Int { BryqoAppState.xpGoal(for: profile?.dailyGoalMinutes ?? 10) }

    var dailyGoalTier: String {
        switch profile?.dailyGoalMinutes ?? 10 {
        case 5:  return "Casual"
        case 10: return "Regular"
        case 15: return "Sério"
        default: return "Intenso"
        }
    }

    var dailyGoalProgress: Double {
        guard dailyGoalXp > 0 else { return 0 }
        return min(1.0, Double(progress.dailyXpEarned) / Double(dailyGoalXp))
    }

    // MARK: - Onboarding

    func completeOnboarding(displayName: String, experience: String, goal: String, dailyGoalMinutes: Int) {
        profile = OnboardingProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "construtor" : displayName,
            experience: experience,
            goal: goal,
            dailyGoalMinutes: dailyGoalMinutes,
            accountCreatedDate: Date()
        )
        save()
    }

    func resetOnboarding() {
        profile = nil
        save()
    }

    // MARK: - Lesson

    func isLessonCompleted(_ lesson: Lesson) -> Bool {
        progress.completedLessonIds.contains(lesson.id)
    }

    func canStartLesson(_ lesson: Lesson, in unit: LearningUnit) -> Bool {
        guard let index = unit.lessons.firstIndex(of: lesson) else { return false }
        if index == 0 { return true }
        return isLessonCompleted(unit.lessons[index - 1])
    }

    func completeLesson(_ lesson: Lesson, mistakeCount: Int = 0) {
        guard !isLessonCompleted(lesson) else { return }

        let hasMistakes = mistakeCount > 0
        progress.completedLessonIds.insert(lesson.id)
        progress.xp += lesson.xpReward
        progress.earnedMaterials.append(lesson.materialReward)

        if hasMistakes {
            if progress.hearts > 0 {
                progress.hearts -= 1
                progress.heartsUpdatedAt = Date()
            }
        } else {
            progress.perfectLessonCount += 1
            if progress.hearts < BryqoAppState.heartsMax {
                progress.hearts += 1
                // Don't reset heartsUpdatedAt — regen continues for remaining lost hearts
            }
        }

        updateStreak()
        progress.dailyXpEarned += lesson.xpReward
        scheduleReview(lessonId: lesson.id, mistakeCount: mistakeCount)
        checkAchievements()
        save()
        BryqoAnalytics.lessonCompleted(lessonId: lesson.id, xpEarned: lesson.xpReward, perfect: !hasMistakes)

        if let uid = cloudUIDForWrites {
            let mc = mistakeCount
            let lessonId = lesson.id
            Task { await cloudStore.saveLessonProgress(uid: uid, lessonId: lessonId, mistakes: mc) }
        }

        if notificationsEnabled {
            notificationManager.cancelAndRescheduleFromTomorrow()
        }
    }

    func loseHeart() {
        guard progress.hearts > 0 else { return }
        progress.hearts -= 1
        progress.heartsUpdatedAt = Date()
        save()
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "bryqo.notifications.enabled")
        if enabled {
            Task {
                let granted = await notificationManager.requestAndSchedule()
                if !granted {
                    await MainActor.run {
                        self.notificationsEnabled = false
                        UserDefaults.standard.set(false, forKey: "bryqo.notifications.enabled")
                    }
                }
            }
        } else {
            notificationManager.cancel()
        }
    }

    // MARK: - Spaced Repetition (SM-2)

    /// Global lookup of a lesson across every unit — reviews reference lessons by id.
    func lesson(for id: String) -> Lesson? {
        content.lesson(for: id)
    }

    // MARK: - Spaced repetition (SwiftData)

    /// Reviews whose date has arrived, most overdue first. Filtering and sorting run in the store.
    static func dueReviewsDescriptor(at date: Date) -> FetchDescriptor<LessonReview> {
        FetchDescriptor(
            predicate: #Predicate { $0.nextReviewAt <= date },
            sortBy: [SortDescriptor(\.nextReviewAt)]
        )
    }

    /// Lessons whose next review date has arrived, most overdue first.
    func dueReviews(at date: Date = Date()) -> [Lesson] {
        _ = reviewsRevision
        return fetchReviews(Self.dueReviewsDescriptor(at: date)).compactMap { lesson(for: $0.lessonId) }
    }

    /// Counted in the store, without loading the rows.
    var dueReviewCount: Int {
        _ = reviewsRevision
        do {
            return try modelContext.fetchCount(Self.dueReviewsDescriptor(at: Date()))
        } catch {
            reportPersistenceError(error, "count_due_reviews")
            return 0
        }
    }

    /// The review row for one lesson, if it has entered spaced repetition.
    func review(for lessonId: String) -> LessonReview? {
        var descriptor = FetchDescriptor<LessonReview>(predicate: #Predicate { $0.lessonId == lessonId })
        descriptor.fetchLimit = 1
        return fetchReviews(descriptor).first
    }

    /// Updates the SM-2 schedule for a lesson after it is completed or reviewed:
    /// creates its row the first time, updates it afterwards.
    func scheduleReview(lessonId: String, mistakeCount: Int, now: Date = Date()) {
        let existing = review(for: lessonId)
        let next = SM2Scheduler.schedule(
            quality: SM2Scheduler.quality(forMistakes: mistakeCount),
            for: lessonId,
            from: existing?.reviewState,
            now: now
        )
        if let existing {
            existing.apply(next)
        } else {
            modelContext.insert(LessonReview(next))
        }
        reviewsChanged()
    }

    /// Deletes every review row. Completed lessons and XP stay; lessons simply leave the review queue.
    func resetReviews() {
        do {
            try modelContext.delete(model: LessonReview.self)
        } catch {
            reportPersistenceError(error, "delete_reviews")
        }
        reviewsChanged()
        saveContext(operation: "delete_reviews")
    }

    /// Call after editing review rows directly, so views reading review counts refresh.
    func reviewsChanged() {
        reviewsRevision += 1
    }

    private func fetchReviews(_ descriptor: FetchDescriptor<LessonReview>) -> [LessonReview] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            reportPersistenceError(error, "fetch_reviews")
            return []
        }
    }

    /// Called when the user finishes a *review* session (a lesson already completed).
    /// Reschedules via SM-2 and awards a small XP bonus, without re-adding to completed lessons.
    func completeReview(_ lesson: Lesson, mistakeCount: Int = 0) {
        scheduleReview(lessonId: lesson.id, mistakeCount: mistakeCount)
        if mistakeCount == 0 {
            progress.xp += 5
            progress.dailyXpEarned += 5
        }
        save()
        BryqoAnalytics.lessonCompleted(lessonId: lesson.id, xpEarned: mistakeCount == 0 ? 5 : 0, perfect: mistakeCount == 0)
    }

    // MARK: - Private

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        defer { progress.lastActivityDate = today }

        guard let last = progress.lastActivityDate else {
            progress.streakDays = 1
            checkMilestone(progress.streakDays)
            return
        }

        if Calendar.current.isDate(last, inSameDayAs: today) { return }

        progress.dailyXpEarned = 0

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if Calendar.current.isDate(last, inSameDayAs: yesterday) {
            progress.streakDays += 1
            checkMilestone(progress.streakDays)
        } else {
            if progress.streakFreezeCount > 0 {
                progress.streakFreezeCount -= 1
            } else {
                progress.streakDays = 1
            }
        }
    }

    private func checkMilestone(_ streak: Int) {
        if [7, 30, 100].contains(streak) {
            pendingStreakMilestone = streak
            BryqoAnalytics.streakMilestone(days: streak)
        }
    }

    private func checkAchievements() {
        let count = progress.completedLessonIds.count
        if count >= 1  { progress.earnedAchievementIds.insert("first_lesson") }
        if count >= 5  { progress.earnedAchievementIds.insert("lessons_5") }
        if count >= 10 { progress.earnedAchievementIds.insert("lessons_10") }
        if progress.streakDays >= 3 { progress.earnedAchievementIds.insert("streak_3") }
        if progress.streakDays >= 7 { progress.earnedAchievementIds.insert("streak_7") }
        if progress.xp >= 100  { progress.earnedAchievementIds.insert("xp_100") }
        if progress.xp >= 500  { progress.earnedAchievementIds.insert("xp_500") }
        if progress.perfectLessonCount >= 1 { progress.earnedAchievementIds.insert("perfect") }
        if progress.earnedMaterials.count >= 5 { progress.earnedAchievementIds.insert("materials_5") }
        if currentLevel >= 3 { progress.earnedAchievementIds.insert("level_3") }
    }
}
