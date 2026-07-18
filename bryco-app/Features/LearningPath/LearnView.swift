import SwiftUI

struct LearnView: View {
    let appState: BryqoAppState
    let units: [LearningUnit]

    private var nextLesson: Lesson? {
        for unit in units {
            if let lesson = unit.lessons.first(where: { !appState.isLessonCompleted($0) }) {
                return lesson
            }
        }
        return nil
    }

    private var nextLessonUnitName: String {
        for unit in units {
            if unit.lessons.contains(where: { !appState.isLessonCompleted($0) }) {
                return unit.title
            }
        }
        return ""
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                        header
                        dailyGoalCard
                        continueCard
                        LessonMapView(units: units, appState: appState)
                    }
                    .padding(BryqoTheme.Spacing.xl)
                }
                .background(BryqoTheme.background)
                .onAppear {
                    guard let id = nextLesson?.id else { return }
                    Task {
                        try? await Task.sleep(for: .milliseconds(450))
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text("Olá, \(appState.profile?.displayName ?? "construtor")")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Text("Vamos empilhar mais um bloco hoje?")
                    .font(.body)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: BryqoTheme.Spacing.md) {
                // Global hearts
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: i < appState.progress.hearts ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundStyle(i < appState.progress.hearts ? BryqoTheme.error : BryqoTheme.border)
                    }
                }
                BryqoStatPill(value: "\(appState.progress.streakDays)d", icon: "flame.fill", tint: Color(hex: 0xFF7A20))
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
                    .font(.headline.bold())
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
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(nextLesson == nil ? "Volte à mochila para revisar." : nextLessonUnitName)
                        .font(.headline)
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                HStack(spacing: BryqoTheme.Spacing.sm) {
                    Image(systemName: "arrow.right")
                    Text("Ir")
                }
                .font(.headline.bold())
                .foregroundStyle(Color(hex: 0x082235))
                .frame(width: 92, height: 58)
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

}
