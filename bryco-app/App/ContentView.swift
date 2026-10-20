import SwiftUI

struct ContentView: View {
    let appState: BryqoAppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView(appState: appState)
            } else {
                OnboardingView(appState: appState)
            }
        }
        // Shown on every screen, onboarding included: a store that fails to open looks like
        // a brand-new install, which is exactly when the user needs to know.
        .safeAreaInset(edge: .top, spacing: 0) {
            if let message = appState.persistenceHealth.bannerMessage {
                PersistenceBanner(message: message)
                    .padding(.horizontal, BryqoTheme.Spacing.lg)
                    .padding(.bottom, BryqoTheme.Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: appState.persistenceHealth)
        .tint(BryqoTheme.forest)
        .preferredColorScheme(appState.preferredColorScheme)
    }
}

#Preview {
    ContentView(appState: BryqoAppState())
}
