import SwiftUI

/// Spaced-repetition hub: lists the lessons whose SM-2 schedule is due and lets the user
/// re-play them in review mode. Reached from the "revisões pendentes" card on the Learn screen.
struct ReviewView: View {
    let appState: BryqoAppState

    private var dueLessons: [Lesson] { appState.dueReviews() }

    var body: some View {
        BryqoScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    BrixSpeechBubble(
                        text: dueLessons.isEmpty
                            ? "Tudo em dia! Volte quando alguma lição precisar de reforço."
                            : "Reforçar o que você já aprendeu fixa de vez. Bora revisar?"
                    )

                    if dueLessons.isEmpty {
                        emptyState
                    } else {
                        ForEach(dueLessons) { lesson in
                            NavigationLink(value: lesson) {
                                reviewCard(lesson)
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                }
                .padding(BryqoTheme.Spacing.xl)
            }
        }
        .navigationTitle("Revisar")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Lesson.self) { lesson in
            LessonView(appState: appState, lesson: lesson, mode: .review)
        }
    }

    private func reviewCard(_ lesson: Lesson) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .bryqoFont(22, relativeTo: .title2, weight: .bold)
                .foregroundStyle(BryqoTheme.river)
                .frame(width: 48, height: 48)
                .background(BryqoTheme.river.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline.bold())
                    .foregroundStyle(BryqoTheme.textPrimary)
                Text("Revisão rápida · reforça a memória")
                    .font(.subheadline)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
            .layoutPriority(1)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .bryqoCard()
    }

    private var emptyState: some View {
        VStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: "checkmark.seal.fill")
                .bryqoFont(44, relativeTo: .largeTitle)
                .foregroundStyle(BryqoTheme.success)
            Text("Nenhuma revisão pendente")
                .font(.headline.bold())
                .foregroundStyle(BryqoTheme.textPrimary)
            Text("Conclua novas lições — elas voltam aqui na hora certa para você fixar.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BryqoTheme.Spacing.xxl)
        .bryqoCard()
    }
}
