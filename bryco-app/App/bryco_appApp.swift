import SwiftData
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
                .modelContainer(appState.modelContainer)
                .task {
                    await appState.syncWithCloud()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await appState.syncWithCloud() }
            appState.applyStreakDecay()
            appState.applyHeartRegeneration()
            if appState.notificationsEnabled {
                appState.notificationManager.ensureScheduledIfNeeded()
            }
        }
    }
}
