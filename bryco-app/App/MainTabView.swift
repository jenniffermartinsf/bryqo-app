import SwiftUI

struct MainTabView: View {
    let appState: BryqoAppState
    @State private var selectedTab: BryqoTab = .learn

    var body: some View {
        BryqoScreen {
            ZStack(alignment: .bottom) {
                selectedView
                    .padding(.bottom, 96)

                FloatingTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, BryqoTheme.Spacing.lg)
                    .padding(.bottom, BryqoTheme.Spacing.md)
            }
        }
    }

    @ViewBuilder
    private var selectedView: some View {
        switch selectedTab {
        case .valley:
            ValleyView(appState: appState, unit: BryqoContent.sampleUnit)
        case .learn:
            LearnView(appState: appState, unit: BryqoContent.sampleUnit)
        case .backpack:
            BackpackView(appState: appState, unit: BryqoContent.sampleUnit)
        case .achievements:
            AchievementsView(appState: appState, unit: BryqoContent.sampleUnit)
        case .profile:
            ProfileView(appState: appState)
        }
    }
}

private enum BryqoTab: String, CaseIterable, Identifiable {
    case valley = "Vale"
    case learn = "Aprender"
    case backpack = "Mochila"
    case achievements = "Conquistas"
    case profile = "Perfil"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .valley:
            return "mountain.2.fill"
        case .learn:
            return "map.fill"
        case .backpack:
            return "backpack.fill"
        case .achievements:
            return "rosette"
        case .profile:
            return "person.crop.circle"
        }
    }
}

private struct FloatingTabBar: View {
    @Binding var selectedTab: BryqoTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(BryqoTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .bold))

                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(selectedTab == tab ? BryqoTheme.river : BryqoTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 68)
                    .background {
                        if selectedTab == tab {
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                                .matchedGeometryEffect(id: "selected-tab", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(BryqoTheme.border.opacity(0.9), lineWidth: 1.2)
        }
    }

    @Namespace private var namespace
}
