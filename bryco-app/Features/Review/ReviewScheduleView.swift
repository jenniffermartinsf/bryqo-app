import SwiftUI

/// Bridges the UIKit review schedule into the SwiftUI navigation stack.
struct ReviewScheduleView: View {
    let appState: BryqoAppState

    private var schedule: ReviewSchedule {
        ReviewSchedule.make(
            from: Array(appState.progress.reviewStates.values),
            lessonTitle: { appState.lesson(for: $0)?.title }
        )
    }

    var body: some View {
        ReviewScheduleRepresentable(schedule: schedule)
            .ignoresSafeArea(edges: .bottom)
            .background(BryqoTheme.background)
            .navigationTitle("Agenda")
            .navigationBarTitleDisplayMode(.large)
    }
}

private struct ReviewScheduleRepresentable: UIViewControllerRepresentable {
    let schedule: ReviewSchedule

    func makeUIViewController(context: Context) -> ReviewScheduleViewController {
        ReviewScheduleViewController(schedule: schedule)
    }

    func updateUIViewController(_ viewController: ReviewScheduleViewController, context: Context) {
        viewController.update(with: schedule)
    }
}
