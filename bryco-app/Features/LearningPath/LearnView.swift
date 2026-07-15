import SwiftUI

struct LearnView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    private var nextLesson: Lesson? {
        unit.lessons.first { !appState.isLessonCompleted($0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    header
                    dailyGoalCard
                    continueCard
                    tracksSection
                }
                .padding(BryqoTheme.Spacing.xl)
            }
            .background(BryqoTheme.background)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text("Olá, \(appState.profile?.displayName ?? "construtor")")
                    .font(.system(size: 36, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Text("Vamos empilhar mais um bloco hoje?")
                    .font(.title3)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: BryqoTheme.Spacing.md) {
                BryqoStatPill(value: "\(appState.progress.streakDays) dias", icon: "bolt.fill", tint: BryqoTheme.textSecondary)
                BryqoStatPill(value: "\(appState.progress.xp) XP", icon: "bolt.fill", tint: BryqoTheme.sun)
            }
        }
    }

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack {
                Text("Meta de hoje")
                    .font(.title2.bold())
                    .foregroundStyle(BryqoTheme.textPrimary)
                Spacer()
                Text("0 / \(appState.profile?.dailyGoalMinutes ?? 10) min")
                    .font(.title3.bold())
                    .foregroundStyle(BryqoTheme.textSecondary)
            }

            ProgressView(value: 0.05)
                .tint(BryqoTheme.river)
                .background(Color.white.opacity(0.04))
        }
        .bryqoCard()
    }

    private var continueCard: some View {
        NavigationLink {
            if let nextLesson {
                LessonView(appState: appState, lesson: nextLesson)
            }
        } label: {
            HStack(spacing: BryqoTheme.Spacing.xl) {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
                    Text(nextLesson == nil ? "UNIDADE COMPLETA" : "CONTINUAR")
                        .font(.caption.weight(.black))
                        .tracking(1.6)
                        .foregroundStyle(BryqoTheme.river)

                    Text(nextLesson?.title ?? "Essa parte ficou sólida!")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(nextLesson == nil ? "Volte à mochila para revisar." : "Internet e Redes")
                        .font(.headline)
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: BryqoTheme.Spacing.sm) {
                    Image(systemName: "arrow.right")
                    Text("Ir")
                }
                .font(.title2.bold())
                .foregroundStyle(Color(hex: 0x082235))
                .frame(width: 116, height: 76)
                .background(BryqoTheme.river)
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.button, style: .continuous))
            }
            .padding(BryqoTheme.Spacing.xl)
            .background(BryqoTheme.river.opacity(0.20))
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        }
        .disabled(nextLesson == nil)
        .buttonStyle(.plain)
    }

    private var tracksSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Trilhas")

            trackCard(
                title: "Internet e Redes",
                subtitle: unit.title,
                icon: "wifi",
                tint: BryqoTheme.sun,
                isLocked: false,
                progress: Double(appState.completedLessonCount) / Double(unit.lessons.count)
            )

            trackCard(
                title: "Pensamento Computacional",
                subtitle: "A base de tudo",
                icon: "safari",
                tint: BryqoTheme.river,
                isLocked: true,
                progress: 0
            )

            trackCard(
                title: "Como Computadores Funcionam",
                subtitle: "Conclua a trilha anterior para desbloquear",
                icon: "cpu",
                tint: BryqoTheme.primary,
                isLocked: true,
                progress: 0
            )
        }
    }

    private func trackCard(title: String, subtitle: String, icon: String, tint: Color, isLocked: Bool, progress: Double) -> some View {
        HStack(spacing: BryqoTheme.Spacing.xl) {
            Image(systemName: isLocked ? "lock.fill" : icon)
                .font(.title)
                .foregroundStyle(isLocked ? BryqoTheme.textSecondary : tint)
                .frame(width: 72, height: 72)
                .background((isLocked ? BryqoTheme.textSecondary : tint).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(isLocked ? BryqoTheme.textSecondary : BryqoTheme.textPrimary)

                Text(isLocked ? "Conclua a trilha anterior para desbloquear" : subtitle)
                    .foregroundStyle(BryqoTheme.textSecondary)

                ProgressView(value: progress)
                    .tint(tint)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.title2.bold())
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .bryqoCard(fill: isLocked ? BryqoTheme.surface.opacity(0.58) : BryqoTheme.surface)
    }
}
