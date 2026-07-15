import SwiftUI

struct ReviewView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    private var completedLessons: [Lesson] {
        unit.lessons.filter(appState.isLessonCompleted)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.spacing) {
                    Text("Vamos reforçar alguns pontos da barragem?")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.forest)

                    if completedLessons.isEmpty {
                        emptyState
                    } else {
                        reviewList
                    }
                }
                .padding()
            }
            .background(BryqoTheme.softBackground.ignoresSafeArea())
            .navigationTitle("Revisar")
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Nenhuma revisão pendente", systemImage: "leaf.fill")
                .font(.headline)
            Text("Conclua uma lição para liberar uma revisão rápida dos conceitos estudados.")
                .foregroundStyle(.secondary)
        }
        .bryqoCard()
    }

    private var reviewList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pronto para reforçar")
                .font(.headline)

            ForEach(completedLessons) { lesson in
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(BryqoTheme.river)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                        Text("Revisão curta: 3 minutos")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(BryqoTheme.river.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
            }
        }
        .bryqoCard()
    }
}
