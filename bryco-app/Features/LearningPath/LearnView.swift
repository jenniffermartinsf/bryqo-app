import SwiftUI

struct LearnView: View {
    let appState: BryqoAppState
    @Bindable var router: AppRouter
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
        NavigationStack(path: $router.learnPath) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: BryqoTheme.Spacing.lg) {
                        if appState.content.showsStaleContentNotice {
                            staleContentNotice
                                .padding(.horizontal, BryqoTheme.Spacing.xl)
                                .padding(.top, BryqoTheme.Spacing.lg)
                        }
                        if appState.dueReviewCount > 0 {
                            reviewBanner(count: appState.dueReviewCount)
                                .padding(.horizontal, BryqoTheme.Spacing.xl)
                                .padding(.top, BryqoTheme.Spacing.lg)
                        }
                        LessonMapView(units: units, appState: appState) { lesson in
                            router.learnPath.append(.lesson(lesson))
                        }
                        .padding(BryqoTheme.Spacing.xl)
                    }
                }
                .background(BryqoTheme.background)
                .learnRouteDestinations(appState: appState)
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

    /// The only network problem the user ever sees: a week without reaching the server.
    private var staleContentNotice: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: "wifi.exclamationmark")
                .font(.headline)
                .foregroundStyle(BryqoTheme.textSecondary)
                .accessibilityHidden(true)
            Text("Conecte-se à internet para receber lições novas. Você pode continuar estudando normalmente.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BryqoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .bryqoCard()
        .accessibilityElement(children: .combine)
    }

    private func reviewBanner(count: Int) -> some View {
        NavigationLink(value: LearnRoute.review) {
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
