import SwiftData
import SwiftUI
import FirebaseCore

@main
struct bryco_appApp: App {
    @State private var appState: BryqoAppState
    @Environment(\.scenePhase) private var scenePhase

    init() {
        FirebaseApp.configure()
        let appState = BryqoAppState()
        #if DEBUG
        // Screenshots and UI tests: `-BryqoSkipOnboarding` starts on the tabs with a sample profile.
        if ProcessInfo.processInfo.arguments.contains("-BryqoSkipOnboarding"), appState.profile == nil {
            appState.completeOnboarding(
                displayName: "Jenni", experience: "Iniciante", goal: "Construir uma base", dailyGoalMinutes: 10
            )
        }
        #endif
        _appState = State(wrappedValue: appState)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .modelContainer(appState.modelContainer)
                .task {
                    // Back online: resume a content fetch that failed for lack of connection.
                    for await isOnline in ConnectivityMonitor.updates() where isOnline {
                        await appState.content.connectionRestored()
                    }
                }
                .task {
                    async let content: Void = appState.content.refresh()
                    async let cloud: Void = appState.syncWithCloud()
                    _ = await (content, cloud)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await appState.syncWithCloud() }
            Task { await appState.content.refresh() }
            appState.appBecameActive()
            if appState.notificationsEnabled {
                Task { await appState.notificationManager.ensureScheduledIfNeeded() }
            }
        }
    }
}
