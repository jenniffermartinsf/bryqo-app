import SwiftUI

struct AchievementsView: View {
    let appState: BryqoAppState

    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Conquistas")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Picker("", selection: $selectedTab) {
                    Text("Conquistas").tag(0)
                    Text("Ranking").tag(1)
                }
                .pickerStyle(.segmented)

                if selectedTab == 0 {
                    achievementsContent
                        .transition(.opacity)
                } else {
                    leaderboardContent
                        .transition(.opacity)
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xxxl)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
        }
    }

    // MARK: - Conquistas Tab

    private var achievementsContent: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            levelCard
            statsRow
            activityHeatmap
            achievementsGrid
        }
    }

    // Level + XP progress card
    private var levelCard: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                    Text("Nível \(appState.currentLevel)")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("\(appState.progress.xp) / \(appState.xpForNextLevel) XP")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "rosette")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(BryqoTheme.river)
                    .frame(width: 60, height: 60)
                    .background(BryqoTheme.river.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(BryqoTheme.border).frame(height: 12)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [BryqoTheme.river, BryqoTheme.primary],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: max(12, geo.size.width * appState.xpProgressInLevel), height: 12)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appState.xpProgressInLevel)
                }
            }
            .frame(height: 12)

            Text(levelCaption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .bryqoCard()
    }

    private var levelCaption: String {
        let level = appState.currentLevel
        switch level {
        case 1: return "Aprendiz — você está construindo sua base."
        case 2: return "Estudante — os blocos estão se encaixando."
        case 3: return "Desenvolvedor — você pensa como dev."
        case 4: return "Arquiteto — design patterns começam a fazer sentido."
        case 5...: return "Engenheiro — domínio verdadeiro dos fundamentos."
        default: return ""
        }
    }

    // 3 stat pills
    private var statsRow: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            statCard(icon: "flame.fill",          value: "\(appState.progress.streakDays)", label: "Sequência",  tint: Color(hex: 0xFF7A20))
            statCard(icon: "bolt.fill",            value: "\(appState.progress.xp)",         label: "XP total",   tint: BryqoTheme.sun)
            statCard(icon: "checkmark.seal.fill",  value: "\(appState.completedLessonCount)", label: "Lições",     tint: BryqoTheme.success)
        }
    }

    // Activity heatmap
    private var activityHeatmap: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Últimos 35 dias")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(0..<35, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(index < appState.completedLessonCount ? BryqoTheme.primary : BryqoTheme.primary.opacity(0.12))
                        .frame(height: 22)
                }
            }
        }
        .bryqoCard()
    }

    // Achievements grid
    private var achievementsGrid: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Marcos")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BryqoTheme.Spacing.lg) {
                ForEach(BryqoAppState.allAchievements) { achievement in
                    achievementCard(achievement)
                }
            }
        }
    }

    private func achievementCard(_ achievement: Achievement) -> some View {
        let unlocked = appState.progress.earnedAchievementIds.contains(achievement.id)
        let tint = rarityColor(achievement.rarity)

        return VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
            HStack(alignment: .top) {
                Image(systemName: unlocked ? achievement.icon : "lock.fill")
                    .font(.title2)
                    .foregroundStyle(unlocked ? tint : BryqoTheme.stone)

                Spacer()

                rarityBadge(achievement.rarity, unlocked: unlocked)
            }

            Text(achievement.title)
                .font(.headline.bold())
                .foregroundStyle(unlocked ? BryqoTheme.textPrimary : BryqoTheme.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(BryqoTheme.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .bryqoCard(
            fill: unlocked ? tint.opacity(0.08) : BryqoTheme.surface.opacity(0.5),
            border: unlocked ? tint.opacity(0.3) : BryqoTheme.border
        )
    }

    @ViewBuilder
    private func rarityBadge(_ rarity: Achievement.Rarity, unlocked: Bool) -> some View {
        if unlocked {
            switch rarity {
            case .common:
                EmptyView()
            case .rare:
                rarityPill("RARO", color: BryqoTheme.river)
            case .epic:
                rarityPill("ÉPICO", color: BryqoTheme.sun)
            }
        }
    }

    private func rarityPill(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 9, weight: .black))
            .tracking(0.8)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }

    private func rarityColor(_ rarity: Achievement.Rarity) -> Color {
        switch rarity {
        case .common: return BryqoTheme.success
        case .rare:   return BryqoTheme.river
        case .epic:   return BryqoTheme.sun
        }
    }

    // MARK: - Ranking Tab

    private var leaderboardContent: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                BryqoSectionTitle(title: "Ranking de amigos")
                Text("Dados simulados — sincronização com amigos chegará em breve.")
                    .font(.caption)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }

            VStack(spacing: BryqoTheme.Spacing.md) {
                ForEach(leaderboardEntries) { entry in
                    leaderboardRow(entry)
                }
            }
        }
    }

    private func leaderboardRow(_ entry: LeaderboardEntry) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            // Rank number
            Text(entry.rank <= 3 ? rankMedal(entry.rank) : "#\(entry.rank)")
                .font(.system(size: entry.rank <= 3 ? 22 : 15, weight: .black, design: .rounded))
                .foregroundStyle(rankColor(entry.rank))
                .frame(width: 36, alignment: .center)

            // Avatar
            if entry.isCurrentUser {
                BrixAvatar(size: 44)
            } else {
                ZStack {
                    Circle()
                        .fill(BryqoTheme.surface)
                        .frame(width: 44, height: 44)
                    Text(String(entry.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
            }

            // Name + streak
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.headline.bold())
                    .foregroundStyle(entry.isCurrentUser ? BryqoTheme.river : BryqoTheme.textPrimary)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: 0xFF7A20))
                    Text("\(entry.streakDays) dias")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
            }
            .layoutPriority(1)

            Spacer()

            Text("\(entry.xp) XP")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(entry.isCurrentUser ? BryqoTheme.river : BryqoTheme.textPrimary)
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(entry.isCurrentUser ? BryqoTheme.river.opacity(0.1) : BryqoTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                .strokeBorder(
                    entry.isCurrentUser ? BryqoTheme.river.opacity(0.4) : BryqoTheme.border,
                    lineWidth: 1.5
                )
        }
    }

    private func rankMedal(_ rank: Int) -> String {
        switch rank { case 1: "🥇"; case 2: "🥈"; default: "🥉" }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return BryqoTheme.sun
        case 2: return BryqoTheme.stone
        case 3: return Color(hex: 0xCD7F32)
        default: return BryqoTheme.textSecondary
        }
    }

    // MARK: - Helpers

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
        .frame(height: 100)
        .bryqoCard(padding: BryqoTheme.Spacing.md)
    }

    // MARK: - Mock Leaderboard

    private var leaderboardEntries: [LeaderboardEntry] {
        let userName = appState.profile?.displayName ?? "Você"

        var entries: [LeaderboardEntry] = [
            LeaderboardEntry(rank: 0, name: "Ana Dev",      xp: 1240, streakDays: 14),
            LeaderboardEntry(rank: 0, name: "Carlos C.",    xp: 870,  streakDays: 9),
            LeaderboardEntry(rank: 0, name: "Mariana P.",   xp: 650,  streakDays: 21),
            LeaderboardEntry(rank: 0, name: "João K.",      xp: 320,  streakDays: 5),
            LeaderboardEntry(rank: 0, name: "Luiza R.",     xp: 180,  streakDays: 3),
            LeaderboardEntry(rank: 0, name: "Rafael A.",    xp: 70,   streakDays: 1),
            LeaderboardEntry(rank: 0, name: userName, xp: appState.progress.xp, streakDays: appState.progress.streakDays, isCurrentUser: true),
        ]

        entries.sort { $0.xp > $1.xp }
        return entries.enumerated().map { idx, entry in
            LeaderboardEntry(rank: idx + 1, name: entry.name, xp: entry.xp, streakDays: entry.streakDays, isCurrentUser: entry.isCurrentUser)
        }
    }
}

// MARK: - Supporting Types

private struct LeaderboardEntry: Identifiable {
    let rank: Int
    let name: String
    let xp: Int
    let streakDays: Int
    var isCurrentUser: Bool = false

    var id: Int { rank }
}
