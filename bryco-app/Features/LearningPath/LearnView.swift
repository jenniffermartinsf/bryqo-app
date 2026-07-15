import SwiftUI

struct LearnView: View {
    let appState: BryqoAppState
    let unit: LearningUnit

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.spacing) {
                    dailyHeader
                    ValleyProgressView(completedLessons: appState.completedLessonCount, totalLessons: unit.lessons.count)
                    unitHeader
                    lessonList
                }
                .padding()
            }
            .background(BryqoTheme.softBackground.ignoresSafeArea())
            .navigationTitle("Aprender")
        }
    }

    private var dailyHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vamos construir mais um pouco?")
                .font(.title2.bold())
                .foregroundStyle(BryqoTheme.forest)

            Text("Falta só um bloco hoje. Sua meta é \(appState.profile?.dailyGoalMinutes ?? 10) minutos.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(appState.progress.xp) XP", systemImage: "sparkles")
                Label("\(appState.progress.streakDays) dia", systemImage: "flame.fill")
                Label("\(appState.completedLessonCount)/\(unit.lessons.count)", systemImage: "checkmark.seal.fill")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BryqoTheme.forest)
        }
        .bryqoCard()
    }

    private var unitHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(unit.title)
                .font(.title3.bold())

            Text(unit.subtitle)
                .foregroundStyle(.secondary)
        }
    }

    private var lessonList: some View {
        VStack(spacing: 12) {
            ForEach(Array(unit.lessons.enumerated()), id: \.element.id) { index, lesson in
                let isCompleted = appState.isLessonCompleted(lesson)
                let isUnlocked = appState.canStartLesson(lesson, in: unit)

                NavigationLink {
                    LessonView(appState: appState, lesson: lesson)
                } label: {
                    LessonRow(
                        number: index + 1,
                        lesson: lesson,
                        isCompleted: isCompleted,
                        isUnlocked: isUnlocked
                    )
                }
                .disabled(!isUnlocked)
                .buttonStyle(.plain)
                .accessibilityHint(isUnlocked ? "Abrir lição" : "Conclua a lição anterior para desbloquear")
            }
        }
    }
}

private struct LessonRow: View {
    let number: Int
    let lesson: Lesson
    let isCompleted: Bool
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(isUnlocked ? 1 : 0.35))
                    .frame(width: 44, height: 44)

                Image(systemName: statusIcon)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Lição \(number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                Text(lesson.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(lesson.estimatedMinutes) min")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(BryqoTheme.river.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous)
                .stroke(isCompleted ? BryqoTheme.leaf : .clear, lineWidth: 2)
        }
    }

    private var statusIcon: String {
        if isCompleted {
            return "checkmark"
        }

        return isUnlocked ? "play.fill" : "lock.fill"
    }

    private var statusColor: Color {
        if isCompleted {
            return BryqoTheme.leaf
        }

        return isUnlocked ? BryqoTheme.forest : BryqoTheme.stone
    }
}
