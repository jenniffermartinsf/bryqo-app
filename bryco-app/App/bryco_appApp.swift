import SwiftUI

@main
struct bryco_appApp: App {
    @State private var appState = BryqoAppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, appState.notificationsEnabled else { return }
            appState.notificationManager.ensureScheduledIfNeeded()
        }
    }
}
