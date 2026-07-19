import SwiftUI
import Observation

@Observable
final class BryqoAppState {
    var profile: OnboardingProfile?
    var progress = UserProgress()

    // Light mode is default; persisted to UserDefaults
    var isLightMode: Bool = true {
        didSet { UserDefaults.standard.set(isLightMode, forKey: "bryqo.isLightMode") }
    }

    // Avatar image data persisted to Documents directory
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
        // Restore persisted light-mode preference; default is true (light)
        if let saved = UserDefaults.standard.object(forKey: "bryqo.isLightMode") as? Bool {
            isLightMode = saved
        }
        avatarImageData = try? Data(contentsOf: BryqoAppState.avatarFileURL)
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

    // XP required to reach level N (index = level - 1)
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

    // MARK: - Onboarding

    func completeOnboarding(displayName: String, experience: String, goal: String, dailyGoalMinutes: Int) {
        profile = OnboardingProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "construtor" : displayName,
            experience: experience,
            goal: goal,
            dailyGoalMinutes: dailyGoalMinutes,
            accountCreatedDate: Date()
        )
    }

    func resetOnboarding() {
        profile = nil
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

        // Hearts: perfect play earns +1 heart (capped at 5), mistakes lose 1
        if hasMistakes {
            progress.hearts = max(0, progress.hearts - 1)
        } else {
            progress.perfectLessonCount += 1
            progress.hearts = min(5, progress.hearts + 1)
        }

        updateStreak()
        checkAchievements()
    }

    func loseHeart() {
        progress.hearts = max(0, progress.hearts - 1)
    }

    // MARK: - Private

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        defer { progress.lastActivityDate = today }

        guard let last = progress.lastActivityDate else {
            progress.streakDays = 1
            return
        }

        if Calendar.current.isDate(last, inSameDayAs: today) {
            return  // already studied today, keep streak
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        if Calendar.current.isDate(last, inSameDayAs: yesterday) {
            progress.streakDays += 1
        } else {
            progress.streakDays = 1  // streak broken
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
