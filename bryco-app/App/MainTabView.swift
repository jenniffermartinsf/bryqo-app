import SwiftUI

struct MainTabView: View {
    let appState: BryqoAppState
    @State private var router = AppRouter()

    var body: some View {
        // The system tab bar: Liquid Glass on iPhone, a top bar that can become a sidebar on iPad.
        TabView(selection: $router.selectedTab) {
            ForEach(BryqoTab.allCases) { tab in
                Tab(tab.rawValue, systemImage: tab.icon, value: tab) {
                    view(for: tab)
                        .background(BryqoTheme.background)
                        .toolbarVisibility(router.hidesTabBar ? .hidden : .visible, for: .tabBar)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tint(BryqoTheme.river)
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
            // Check heart regeneration and midnight every minute while the app is active
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                appState.startNewDayIfNeeded()
                appState.applyHeartRegeneration()
            }
        }
    }

    private var units: [LearningUnit] { appState.content.units }

    @ViewBuilder
    private func view(for tab: BryqoTab) -> some View {
        switch tab {
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
