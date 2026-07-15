import SwiftUI

struct ValleyView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
                    Text("Vale")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("Cada lição transforma o ambiente. Sua barragem cresce um bloco por vez.")
                        .font(.title3)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .lineSpacing(4)
                }

                ValleyProgressView(completedLessons: appState.completedLessonCount, totalLessons: unit.lessons.count)

                BrixSpeechBubble(text: appState.completedLessonCount == 0 ? "Vamos colocar o primeiro bloco?" : "Mais um bloco colocado. Essa estrutura está ficando sólida.")

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                    BryqoSectionTitle(title: "Construções")
                    constructionRow("Barragem inicial", icon: "water.waves", progress: appState.completedLessonCount, target: 5)
                    constructionRow("Ponte do fluxo", icon: "point.topleft.down.curvedto.point.bottomright.up", progress: max(appState.completedLessonCount - 2, 0), target: 3)
                    constructionRow("Oficina do Brix", icon: "hammer.fill", progress: max(appState.completedLessonCount - 4, 0), target: 1)
                }
            }
            .padding(BryqoTheme.Spacing.xl)
        }
    }

    private func constructionRow(_ title: String, icon: String, progress: Int, target: Int) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(BryqoTheme.river)
                .frame(width: 52, height: 52)
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
