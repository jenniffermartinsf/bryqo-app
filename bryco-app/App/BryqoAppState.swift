import SwiftUI
import Observation
import SwiftData

@Observable
final class BryqoAppState {
    @ObservationIgnored private let modelContainer: ModelContainer
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private var persistedState: PersistedUserState
    @ObservationIgnored let notificationManager = BryqoNotificationManager()
    @ObservationIgnored let authManager = BryqoAuthManager()
    @ObservationIgnored private let firestoreService = BryqoFirestoreService()

    var profile: OnboardingProfile?
    var progress = UserProgress()

    var isLightMode: Bool = true {
        didSet { UserDefaults.standard.set(isLightMode, forKey: "bryqo.isLightMode") }
    }
    var notificationsEnabled: Bool = false
    var pendingStreakMilestone: Int? = nil

    var avatarImageData: Data? = nil {
        didSet {
            if let data = avatarImageData {
                try? data.write(to: BryqoAppState.avatarFileURL)
            } else {
                try? FileManager.default.removeItem(at: BryqoAppState.avatarFileURL)
            }
        }
    }

    private static var avatarFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("bryqo_avatar.jpg")
    }

    init() {
        let schema = Schema([PersistedUserState.self])
        let diskConfig = ModelConfiguration(schema: schema)

        if let container = try? ModelContainer(
            for: schema,
            migrationPlan: BryqoMigrationPlan.self,
            configurations: diskConfig
        ) {
            modelContainer = container
        } else {
            modelContainer = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            )
        }

        modelContext = ModelContext(modelContainer)

        let descriptor = FetchDescriptor<PersistedUserState>()
        let results = (try? modelContext.fetch(descriptor)) ?? []
        if let existing = results.first {
            persistedState = existing
        } else {
            let newState = PersistedUserState()
            modelContext.insert(newState)
            persistedState = newState
            try? modelContext.save()
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
            dailyXpEarned: persistedState.dailyXpEarned,
            heartsUpdatedAt: persistedState.heartsUpdatedAt
        )

        if let last = progress.lastActivityDate,
           !Calendar.current.isDate(last, inSameDayAs: Date()) {
            progress.dailyXpEarned = 0
            persistedState.dailyXpEarned = 0
            try? modelContext.save()
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
        avatarImageData = try? Data(contentsOf: BryqoAppState.avatarFileURL)

        applyHeartRegeneration()
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

    func syncFromFirestore() async {
        guard let uid = authManager.currentUID else { return }
        let remote = await firestoreService.loadUserData(uid: uid)
        guard let remote else {
            await firestoreService.saveUserData(uid: uid, snapshot: buildSnapshot())
            return
        }
        mergeRemote(remote)
    }

    private func mergeRemote(_ remote: FirestoreUserSnapshot) {
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
        persistedState.dailyXpEarned = progress.dailyXpEarned
        persistedState.displayName = profile?.displayName
        persistedState.experience = profile?.experience
        persistedState.goal = profile?.goal
        persistedState.dailyGoalMinutes = profile?.dailyGoalMinutes ?? 20
        persistedState.accountCreatedDate = profile?.accountCreatedDate ?? Date()
        try? modelContext.save()

        if let uid = authManager.currentUID {
            let snapshot = buildSnapshot()
            Task { await firestoreService.saveUserData(uid: uid, snapshot: snapshot) }
        }
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

    var dailyGoalXp: Int {
        switch profile?.dailyGoalMinutes ?? 20 {
        case ..<10: return 50
        case 10..<20: return 100
        case 20..<30: return 150
        default: return 200
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
        checkAchievements()
        save()
        BryqoAnalytics.lessonCompleted(lessonId: lesson.id, xpEarned: lesson.xpReward, perfect: !hasMistakes)

        if let uid = authManager.currentUID {
            let mc = mistakeCount
            let lessonId = lesson.id
            Task { await firestoreService.saveLessonProgress(uid: uid, lessonId: lessonId, mistakes: mc) }
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
