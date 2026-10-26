import SwiftUI

struct MainTabView: View {
    let appState: BryqoAppState
    @State private var router = AppRouter()

    var body: some View {
        BryqoScreen {
            ZStack(alignment: .bottom) {
                selectedView
                    .padding(.bottom, router.hidesTabBar ? 0 : 96)

                if !router.hidesTabBar {
                    FloatingTabBar(selectedTab: $router.selectedTab)
                        .padding(.horizontal, BryqoTheme.Spacing.lg)
                        .padding(.bottom, BryqoTheme.Spacing.md)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: 0.25), value: router.hidesTabBar)
        }
        .onOpenURL { url in
            router.handle(url)
        }
        .overlay {
            if let milestone = appState.pendingStreakMilestone {
                StreakMilestoneView(days: milestone) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        appState.pendingStreakMilestone = nil
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.3), value: appState.pendingStreakMilestone != nil)
        .task {
            // Check heart regeneration every minute while the app is active
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                appState.applyHeartRegeneration()
            }
        }
    }

    private var units: [LearningUnit] { appState.content.units }

    @ViewBuilder
    private var selectedView: some View {
        switch router.selectedTab {
        case .valley:
            ValleyView(appState: appState, router: router, unit: units[0], units: units)
        case .learn:
            LearnView(appState: appState, router: router, units: units)
        case .backpack:
            BackpackView(appState: appState, unit: units[0])
        case .achievements:
            AchievementsView(appState: appState)
        case .profile:
            ProfileView(appState: appState)
        }
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: BryqoTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BryqoTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .bryqoFont(20, relativeTo: .title2, weight: .bold)

                        Text(tab.rawValue)
                            .bryqoFont(10, weight: .bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(selectedTab == tab ? BryqoTheme.river : BryqoTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                                .matchedGeometryEffect(id: "selected-tab", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(BryqoTheme.border.opacity(0.9), lineWidth: 1.2)
        }
    }

    @Namespace private var namespace
}
