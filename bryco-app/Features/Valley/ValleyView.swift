import SwiftUI

struct ValleyView: View {
    let appState: BryqoAppState
    let unit: LearningUnit
    let units: [LearningUnit]

    @State private var selectedLesson: Lesson?

    private var nextLesson: Lesson? {
        for u in units {
            if let lesson = u.lessons.first(where: { !appState.isLessonCompleted($0) }) {
                return lesson
            }
        }
        return nil
    }

    private var nextLessonUnit: LearningUnit? {
        units.first { u in u.lessons.contains { !appState.isLessonCompleted($0) } }
    }

    private var unitCompletedCount: Int {
        guard let u = nextLessonUnit else { return 0 }
        return u.lessons.filter { appState.isLessonCompleted($0) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    header
                    ValleyProgressView(
                        completedLessons: appState.completedLessonCount,
                        totalLessons: unit.lessons.count
                    )
                    continueCard
                    BrixSpeechBubble(text: appState.completedLessonCount == 0
                        ? "Vamos colocar o primeiro bloco?"
                        : "Mais um bloco colocado. Essa estrutura está ficando sólida.")
                    constructions
                }
                .padding(BryqoTheme.Spacing.xl)
            }
            .background(BryqoTheme.background)
            .navigationDestination(item: $selectedLesson) { lesson in
                LessonView(appState: appState, lesson: lesson)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bom te ver de volta")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)

                Text(appState.profile?.displayName ?? "construtor")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)
            }

            Spacer()

            HStack(spacing: BryqoTheme.Spacing.sm) {
                BryqoStatPill(
                    value: "\(appState.progress.streakDays)",
                    icon: "flame.fill",
                    tint: BryqoTheme.coral
                )
                BryqoStatPill(
                    value: "\(appState.progress.xp) XP",
                    icon: "star.fill",
                    tint: BryqoTheme.sun
                )
            }
        }
    }

    // MARK: - Continue Card

    private var continueCard: some View {
        Button {
            if let lesson = nextLesson {
                selectedLesson = lesson
            }
        } label: {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                Text(nextLessonUnit.map { "TRACK · \($0.title.uppercased())" } ?? "UNIDADE COMPLETA")
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(BryqoTheme.river)

                Text(nextLesson?.title ?? "Toda a trilha foi concluída!")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                // Segmented progress bar
                if let u = nextLessonUnit {
                    HStack(spacing: 5) {
                        ForEach(0..<u.lessons.count, id: \.self) { i in
                            let completed = appState.isLessonCompleted(u.lessons[i])
                            let isCurrent = !completed && i == unitCompletedCount
                            RoundedRectangle(cornerRadius: 3)
                                .fill(completed
                                    ? BryqoTheme.primary
                                    : isCurrent ? BryqoTheme.sun : BryqoTheme.border)
                                .frame(height: 6)
                        }
                    }
                }

                HStack {
                    Spacer()
                    HStack(spacing: BryqoTheme.Spacing.sm) {
                        Text("Continuar construindo")
                            .font(.headline.bold())
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, BryqoTheme.Spacing.xl)
                    .frame(height: 46)
                    .background(nextLesson != nil ? BryqoTheme.primary : BryqoTheme.stone)
                    .clipShape(Capsule())
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BryqoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                    .stroke(BryqoTheme.border, lineWidth: 1.5)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(nextLesson == nil)
    }

    // MARK: - Constructions

    private var constructions: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Construções")
            constructionRow("Barragem inicial", icon: "water.waves", progress: appState.completedLessonCount, target: 5)
            constructionRow("Ponte do fluxo", icon: "point.topleft.down.curvedto.point.bottomright.up", progress: max(appState.completedLessonCount - 2, 0), target: 3)
            constructionRow("Oficina do Brix", icon: "hammer.fill", progress: max(appState.completedLessonCount - 4, 0), target: 1)
        }
    }

    private func constructionRow(_ title: String, icon: String, progress: Int, target: Int) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(BryqoTheme.river)
                .frame(width: 46, height: 46)
                .background(BryqoTheme.river.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textPrimary)

                ProgressView(value: Double(min(progress, target)), total: Double(target))
                    .tint(BryqoTheme.primary)

                Text("\(min(progress, target))/\(target) blocos")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
        }
        .bryqoCard()
    }
}
