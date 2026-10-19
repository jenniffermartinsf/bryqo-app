import Foundation
import Testing
@testable import bryco_app

/// Covers tab/stack state and deep-link handling in `AppRouter`.
@MainActor
@Suite("App router")
struct AppRouterTests {

    private let lesson = LessonFixtures.lesson(steps: [LessonFixtures.conceptStep()])

    @Test("The review deep link opens the review hub on the Learn tab")
    func reviewDeepLink() {
        let router = AppRouter()
        router.selectedTab = .profile
        router.learnPath = [.lesson(lesson)]

        router.handle(URL(string: "bryqo://review")!)

        #expect(router.selectedTab == .learn)
        #expect(router.learnPath == [.review])
    }

    @Test("The learn deep link pops the Learn tab back to its root")
    func learnDeepLink() {
        let router = AppRouter()
        router.learnPath = [.review, .reviewLesson(lesson)]

        router.handle(URL(string: "bryqo://learn")!)

        #expect(router.selectedTab == .learn)
        #expect(router.learnPath.isEmpty)
    }

    @Test("Unrecognized URLs leave navigation untouched", arguments: [
        "https://example.com/review",
        "bryqo://unknown",
        "otherapp://review"
    ])
    func unknownURLIsIgnored(urlString: String) {
        let router = AppRouter()
        router.selectedTab = .profile
        router.valleyPath = [.lesson(lesson)]

        router.handle(URL(string: urlString)!)

        #expect(router.selectedTab == .profile)
        #expect(router.valleyPath == [.lesson(lesson)])
    }

    @Test("Each tab keeps its own stack when switching tabs")
    func stacksSurviveTabSwitch() {
        let router = AppRouter()
        router.learnPath = [.review]

        router.selectedTab = .profile
        router.selectedTab = .learn

        #expect(router.learnPath == [.review])
    }

    @Test("The tab bar hides only while a lesson is on top of the visible tab")
    func tabBarVisibility() {
        let router = AppRouter()
        #expect(!router.hidesTabBar)

        router.learnPath = [.review]
        #expect(!router.hidesTabBar)

        router.learnPath.append(.reviewLesson(lesson))
        #expect(router.hidesTabBar)

        router.selectedTab = .profile
        #expect(!router.hidesTabBar)

        router.selectedTab = .valley
        router.valleyPath = [.lesson(lesson)]
        #expect(router.hidesTabBar)
    }

    @Test("Every deep link survives a round trip through its URL", arguments: BryqoDeepLink.allCases)
    func deepLinkRoundTrip(link: BryqoDeepLink) {
        #expect(BryqoDeepLink(url: link.url) == link)
    }
}
