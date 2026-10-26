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
                    async let content: Void = appState.content.refresh()
                    async let cloud: Void = appState.syncWithCloud()
                    _ = await (content, cloud)
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await appState.syncWithCloud() }
            Task { await appState.content.refresh() }
            appState.applyStreakDecay()
            appState.applyHeartRegeneration()
            if appState.notificationsEnabled {
                appState.notificationManager.ensureScheduledIfNeeded()
            }
        }
    }
}
