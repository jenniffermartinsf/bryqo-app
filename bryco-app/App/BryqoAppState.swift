import SwiftUI
import Observation
import SwiftData

@Observable
final class BryqoAppState {
    // Persistence layer — excluded from observation tracking
    @ObservationIgnored private let modelContainer: ModelContainer
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private var persistedState: PersistedUserState
    @ObservationIgnored let notificationManager = BryqoNotificationManager()

    // In-memory state (observed by Views — no changes needed in Views)
    var profile: OnboardingProfile?
    var progress = UserProgress()

    // Light mode persisted to UserDefaults (fast, single bool)
    var isLightMode: Bool = true {
        didSet { UserDefaults.standard.set(isLightMode, forKey: "bryqo.isLightMode") }
    }

    // Notifications — persisted to UserDefaults; use setNotificationsEnabled() to toggle
    var notificationsEnabled: Bool = false

    // Set when streak crosses a milestone (7 / 30 / 100); cleared after celebration is shown.
    var pendingStreakMilestone: Int? = nil

    // Avatar image persisted to Documents (binary, not SwiftData)
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
        // --- Phase 1: initialize all stored properties without defaults ---
        let schema = Schema([PersistedUserState.self])
        let diskConfig = ModelConfiguration(schema: schema)

        if let container = try? ModelContainer(
            for: schema,
            migrationPlan: BryqoMigrationPlan.self,
            configurations: diskConfig
        ) {
            modelContainer = container
        } else {
            // Fallback to in-memory if disk setup fails (e.g. simulator sandbox issue)
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

        // --- Phase 2: all stored properties initialized — restore from persisted state ---
        progress = UserProgress(
            completedLessonIds: Set(persistedState.completedLessonIds),
            xp: persistedState.xp,
            streakDays: persistedState.streakDays,
            earnedMaterials: persistedState.earnedMaterials,
            hearts: persistedState.hearts,
            lastActivityDate: persistedState.lastActivityDate,
            earnedAchievementIds: Set(persistedState.earnedAchievementIds),
            perfectLessonCount: persistedState.perfectLessonCount,
            streakFreezeCount: persistedState.streakFreezeCount
        )

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
    }

    // Syncs in-memory structs back to the SwiftData model and saves explicitly.
    private func save() {
        persistedState.completedLessonIds = Array(progress.completedLessonIds)
        persistedState.xp = progress.xp
        persistedState.streakDays = progress.streakDays
        persistedState.earnedMaterials = progress.earnedMaterials
        persistedState.hearts = progress.hearts
        persistedState.lastActivityDate = progress.lastActivityDate
        persistedState.earnedAchievementIds = Array(progress.earnedAchievementIds)
        persistedState.perfectLessonCount = progress.perfectLessonCount
        persistedState.streakFreezeCount = progress.streakFreezeCount

        persistedState.displayName = profile?.displayName
        persistedState.experience = profile?.experience
        persistedState.goal = profile?.goal
        persistedState.dailyGoalMinutes = profile?.dailyGoalMinutes ?? 20
        persistedState.accountCreatedDate = profile?.accountCreatedDate ?? Date()

        try? modelContext.save()
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

    var xpForCurrentLevel: Int {
        BryqoAppState.levelThresholds[max(0, currentLevel - 1)]
    }

    var xpForNextLevel: Int {
        let thresholds = BryqoAppState.levelThresholds
        let level = currentLevel
        guard level < thresholds.count else { return thresholds.last ?? 10000 }
        return thresholds[level]
    }

    var xpProgressInLevel: Double {
        let current = Double(progress.xp - xpForCurrentLevel)
        let total = Double(xpForNextLevel - xpForCurrentLevel)
        guard total > 0 else { return 1.0 }
        return min(1.0, current / total)
    }

    // True when the user studied yesterday but not yet today — streak at risk of breaking.
    var isStreakAtRisk: Bool {
        guard progress.streakDays > 0, let last = progress.lastActivityDate else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        return !Calendar.current.isDate(last, inSameDayAs: today)
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

    func completeLesson(_ lesson: Lesson, hasMistakes: Bool = false) {
        guard !isLessonCompleted(lesson) else { return }

        progress.completedLessonIds.insert(lesson.id)
        progress.xp += lesson.xpReward
        progress.earnedMaterials.append(lesson.materialReward)

        if hasMistakes {
            progress.hearts = max(0, progress.hearts - 1)
        } else {
            progress.perfectLessonCount += 1
            progress.hearts = min(5, progress.hearts + 1)
        }

        updateStreak()
        checkAchievements()
        save()
        if notificationsEnabled {
            notificationManager.cancelAndRescheduleFromTomorrow()
        }
    }

    func loseHeart() {
        progress.hearts = max(0, progress.hearts - 1)
        save()
    }

    // Enables or disables the daily reminder. Requests UNUserNotificationCenter
    // permission on first enable; reverts the toggle if permission is denied.
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

        if Calendar.current.isDate(last, inSameDayAs: today) {
            return // already studied today — streak unchanged
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if Calendar.current.isDate(last, inSameDayAs: yesterday) {
            // Consecutive day — extend streak
            progress.streakDays += 1
            checkMilestone(progress.streakDays)
        } else {
            // Missed at least one day
            if progress.streakFreezeCount > 0 {
                // Use a freeze: streak survives, not incremented
                progress.streakFreezeCount -= 1
            } else {
                progress.streakDays = 1
            }
        }
    }

    private func checkMilestone(_ streak: Int) {
        if [7, 30, 100].contains(streak) {
            pendingStreakMilestone = streak
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
