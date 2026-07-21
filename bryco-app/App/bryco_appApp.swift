import SwiftUI
import FirebaseCore

@main
struct bryco_appApp: App {
    @State private var appState: BryqoAppState
    @Environment(\.scenePhase) private var scenePhase

    init() {
        FirebaseApp.configure()
        _appState = State(wrappedValue: BryqoAppState())
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .task {
                    await appState.authManager.signInAnonymouslyIfNeeded()
                    await appState.syncFromFirestore()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            appState.applyHeartRegeneration()
            if appState.notificationsEnabled {
                appState.notificationManager.ensureScheduledIfNeeded()
            }
        }
    }
}
