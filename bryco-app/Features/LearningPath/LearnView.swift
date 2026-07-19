import SwiftUI

struct LearnView: View {
    let appState: BryqoAppState
    let units: [LearningUnit]

    private var nextLesson: Lesson? {
        for unit in units {
            if let lesson = unit.lessons.first(where: { !appState.isLessonCompleted($0) }) {
                return lesson
            }
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LessonMapView(units: units, appState: appState)
                        .padding(BryqoTheme.Spacing.xl)
                }
                .background(BryqoTheme.background)
                .onAppear {
                    guard let id = nextLesson?.id else { return }
                    Task {
                        try? await Task.sleep(for: .milliseconds(450))
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}
