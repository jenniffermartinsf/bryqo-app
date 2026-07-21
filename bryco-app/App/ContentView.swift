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
        .tint(BryqoTheme.forest)
        .preferredColorScheme(appState.preferredColorScheme)
    }
}

#Preview {
    ContentView(appState: BryqoAppState())
}
