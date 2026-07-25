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

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: BryqoTheme.Spacing.lg) {
                        if appState.dueReviewCount > 0 {
                            reviewBanner(count: appState.dueReviewCount)
                                .padding(.horizontal, BryqoTheme.Spacing.xl)
                                .padding(.top, BryqoTheme.Spacing.lg)
                        }
                        LessonMapView(units: units, appState: appState)
                            .padding(BryqoTheme.Spacing.xl)
                    }
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

    private func reviewBanner(count: Int) -> some View {
        NavigationLink {
            ReviewView(appState: appState)
        } label: {
            HStack(spacing: BryqoTheme.Spacing.lg) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .bryqoFont(22, relativeTo: .title2, weight: .bold)
                    .foregroundStyle(BryqoTheme.river)
                    .frame(width: 48, height: 48)
                    .background(BryqoTheme.river.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(count == 1 ? "1 revisão pendente" : "\(count) revisões pendentes")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("Reforce o que já aprendeu")
                        .font(.subheadline)
                        .foregroundStyle(BryqoTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .bryqoCard(fill: BryqoTheme.river.opacity(0.08), border: BryqoTheme.river.opacity(0.25))
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("\(count) revisões pendentes. Reforce o que já aprendeu.")
    }
}
