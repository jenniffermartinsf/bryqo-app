import SwiftUI

struct ContentView: View {
    @State private var appState = BryqoAppState()

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
    ContentView()
}
