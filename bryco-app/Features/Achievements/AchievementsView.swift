import SwiftUI

struct AchievementsView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    private var progress: Double {
        guard !unit.lessons.isEmpty else { return 0 }
        return Double(appState.completedLessonCount) / Double(unit.lessons.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Conquistas")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                statGrid
                activityGrid
                masterySection
                achievementsSection
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xxxl)
        }
    }

    private var statGrid: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            statCard(icon: "bolt.fill", value: "\(appState.progress.xp)", label: "XP total", tint: BryqoTheme.sun)
            statCard(icon: "rosette", value: "Nível 1", label: "\(min(appState.progress.xp, 100))/100", tint: BryqoTheme.river)
            statCard(icon: "flame.fill", value: "\(appState.progress.streakDays)", label: "Sequência", tint: BryqoTheme.sun)
        }
    }

    private var activityGrid: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Últimos 35 dias")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(0..<35, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(index < appState.completedLessonCount ? BryqoTheme.primary : Color.white.opacity(0.035))
                        .frame(height: 22)
                }
            }
        }
        .bryqoCard()
    }

    private var masterySection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Domínio por trilha")
            masteryRow(title: "Internet e Redes", icon: "wifi", tint: BryqoTheme.sun, percent: Int(progress * 100))
            masteryRow(title: "Pensamento Computacional", icon: "safari", tint: BryqoTheme.river, percent: 0)
            masteryRow(title: "Como Computadores Funcionam", icon: "cpu", tint: BryqoTheme.primary, percent: 0)
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Marcos")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BryqoTheme.Spacing.lg) {
                achievement("Primeiro bloco", "Conclua uma lição.", unlocked: appState.completedLessonCount > 0, icon: "checkmark.seal.fill")
                achievement("Ritmo inicial", "Alcance 3 dias.", unlocked: appState.progress.streakDays >= 3, icon: "bolt.fill")
                achievement("Barragem forte", "Conclua a unidade.", unlocked: appState.completedLessonCount == unit.lessons.count, icon: "water.waves")
                achievement("Mochila cheia", "Ganhe 5 materiais.", unlocked: appState.progress.earnedMaterials.count >= 5, icon: "backpack.fill")
            }
        }
    }

    private func statCard(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(spacing: BryqoTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.bold())
                .foregroundStyle(BryqoTheme.textPrimary)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BryqoTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 112)
        .bryqoCard(padding: BryqoTheme.Spacing.md)
    }

    private func masteryRow(title: String, icon: String, tint: Color, percent: Int) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 50, height: 50)
                .background(tint.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(percent)% concluído")
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
            .layoutPriority(1)
        }
        .bryqoCard()
    }

    private func achievement(_ title: String, _ subtitle: String, unlocked: Bool, icon: String) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
            Image(systemName: unlocked ? icon : "lock.fill")
                .font(.title2)
                .foregroundStyle(unlocked ? BryqoTheme.sun : BryqoTheme.stone)

            Text(title)
                .font(.headline)
                .foregroundStyle(unlocked ? BryqoTheme.textPrimary : BryqoTheme.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(BryqoTheme.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .bryqoCard(fill: unlocked ? BryqoTheme.surface : BryqoTheme.surface.opacity(0.55))
    }
}
