import SwiftUI

/// Every screen that can be pushed onto the Learn or Valley navigation stacks.
enum LearnRoute: Hashable {
    case lesson(Lesson)
    case review
    case reviewLesson(Lesson)

    /// Lessons are focused, full-screen flows: the tab bar hides while one is on top.
    var isLesson: Bool {
        switch self {
        case .lesson, .reviewLesson: true
        case .review: false
        }
    }
}

extension View {
    /// Registers the destination for every `LearnRoute`, so any stack that holds
    /// `[LearnRoute]` can push lessons and the review hub.
    func learnRouteDestinations(appState: BryqoAppState) -> some View {
        navigationDestination(for: LearnRoute.self) { route in
            switch route {
            case .lesson(let lesson):
                LessonView(appState: appState, lesson: lesson)
            case .review:
                ReviewView(appState: appState)
            case .reviewLesson(let lesson):
                LessonView(appState: appState, lesson: lesson, mode: .review)
            }
        }
    }
}
