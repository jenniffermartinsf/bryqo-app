import SwiftUI

struct BackpackView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    private var completedLessons: [Lesson] {
        unit.lessons.filter(appState.isLessonCompleted)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Mochila")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Text("Materiais, revisões e reforços ficam aqui para você continuar construindo.")
                    .font(.title3)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .lineSpacing(4)

                materialsSection
                reviewSection
            }
            .padding(BryqoTheme.Spacing.xl)
        }
    }

    private var materialsSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Materiais")

            if appState.progress.earnedMaterials.isEmpty {
                BrixSpeechBubble(text: "Conclua uma lição para guardar o primeiro material na mochila.")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BryqoTheme.Spacing.lg) {
                    ForEach(Array(appState.progress.earnedMaterials.enumerated()), id: \.offset) { _, material in
                        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
                            Image(systemName: materialIcon(material))
                                .font(.largeTitle)
                                .foregroundStyle(BryqoTheme.sun)

                            Text(material)
                                .font(.headline)
                                .foregroundStyle(BryqoTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bryqoCard()
                    }
                }
            }
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Reforços")

            if completedLessons.isEmpty {
                emptyReview
            } else {
                ForEach(completedLessons) { lesson in
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title2)
                            .foregroundStyle(BryqoTheme.river)

                        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                            Text(lesson.title)
                                .font(.headline)
                                .foregroundStyle(BryqoTheme.textPrimary)
                            Text("Revisão rápida disponível")
                                .foregroundStyle(BryqoTheme.textSecondary)
                        }

                        Spacer()
                    }
                    .bryqoCard()
                }
            }
        }
    }

    private var emptyReview: some View {
        VStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(BryqoTheme.success)

            Text("Tudo em dia")
                .font(.title2.bold())
                .foregroundStyle(BryqoTheme.textPrimary)

            Text("Complete lições para acumular conceitos de revisão.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .bryqoCard()
    }

    private func materialIcon(_ material: String) -> String {
        switch material {
        case "Madeira":
            return "tree.fill"
        case "Pedra":
            return "circle.hexagongrid.fill"
        case "Galhos":
            return "leaf.fill"
        case "Blocos":
            return "square.grid.3x3.fill"
        default:
            return "gearshape.fill"
        }
    }
}
