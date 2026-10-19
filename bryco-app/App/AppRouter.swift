import Foundation
import Observation

/// Navigation state for the whole tab interface. Living outside the views means each tab
/// keeps its stack when the user switches tabs, and deep links can drive navigation.
@Observable
final class AppRouter {
    var selectedTab: BryqoTab = .learn
    var learnPath: [LearnRoute] = []
    var valleyPath: [LearnRoute] = []

    /// True while a lesson is the top screen of the visible tab.
    var hidesTabBar: Bool {
        visiblePath.last?.isLesson ?? false
    }

    private var visiblePath: [LearnRoute] {
        switch selectedTab {
        case .learn: learnPath
        case .valley: valleyPath
        case .backpack, .achievements, .profile: []
        }
    }

    func open(_ deepLink: BryqoDeepLink) {
        selectedTab = .learn
        switch deepLink {
        case .learn:
            learnPath = []
        case .review:
            learnPath = [.review]
        }
    }

    /// Opens a URL the app was launched with; anything unrecognized is ignored.
    func handle(_ url: URL) {
        guard let deepLink = BryqoDeepLink(url: url) else { return }
        open(deepLink)
    }
}
