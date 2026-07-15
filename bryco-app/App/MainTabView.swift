import SwiftUI

struct MainTabView: View {
    let appState: BryqoAppState

    var body: some View {
        TabView {
            LearnView(appState: appState, unit: BryqoContent.sampleUnit)
                .tabItem {
                    Label("Aprender", systemImage: "map.fill")
                }

            ReviewView(appState: appState, unit: BryqoContent.sampleUnit)
                .tabItem {
                    Label("Revisar", systemImage: "arrow.triangle.2.circlepath")
                }

            BryqoProgressView(appState: appState, unit: BryqoContent.sampleUnit)
                .tabItem {
                    Label("Progresso", systemImage: "chart.bar.fill")
                }

            ProfileView(appState: appState)
                .tabItem {
                    Label("Perfil", systemImage: "person.crop.circle")
                }
        }
    }
}
