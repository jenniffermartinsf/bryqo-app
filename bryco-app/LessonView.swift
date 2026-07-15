import SwiftUI

struct LessonView: View {
    let appState: BryqoAppState
    let lesson: Lesson

    @Environment(\.dismiss) private var dismiss
    @State private var stepIndex = 0
    @State private var selectedOptionIds: [String] = []
    @State private var hasAnswered = false

    private var currentStep: LessonStep {
        lesson.steps[stepIndex]
    }

    private var isLastStep: Bool {
        stepIndex == lesson.steps.count - 1
    }

    private var isAnswerCorrect: Bool {
        guard let exercise = currentStep.exercise else {
            return true
        }

        return selectedOptionIds == exercise.correctOptionIds
    }

    var body: some View {
        VStack(spacing: 0) {
            progressHeader

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    stepBadge

                    Text(currentStep.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(BryqoTheme.forest)

                    if !currentStep.body.isEmpty {
                        Text(currentStep.body)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }

                    if let exercise = currentStep.exercise {
                        exerciseView(exercise)
                    }
                }
                .padding()
            }

            bottomBar
        }
        .background(BryqoTheme.softBackground.ignoresSafeArea())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(stepIndex + 1), total: Double(lesson.steps.count))
                .tint(BryqoTheme.forest)

            HStack {
                Label("\(lesson.xpReward) XP", systemImage: "sparkles")
                Spacer()
                Text("Etapa \(stepIndex + 1) de \(lesson.steps.count)")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
    }

    private var stepBadge: some View {
        Label(stepLabel, systemImage: stepIcon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BryqoTheme.forest)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(BryqoTheme.leaf.opacity(0.16))
            .clipShape(Capsule())
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if hasAnswered, let exercise = currentStep.exercise {
                feedbackView(exercise: exercise)
            }

            Button {
                advance()
            } label: {
                Label(isLastStep ? "Concluir lição" : "Continuar", systemImage: isLastStep ? "checkmark.seal.fill" : "arrow.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(currentStep.exercise != nil && !hasAnswered)
        }
        .padding()
        .background(.background)
    }

    private func exerciseView(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(exercise.prompt)
                .font(.headline)

            ForEach(exercise.options) { option in
                Button {
                    select(option)
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: optionIcon(option))
                            .foregroundStyle(optionColor(option))

                        Text(option.text)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding()
                    .background(optionBackground(option))
                    .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(hasAnswered)
            }
        }
        .bryqoCard()
    }

    private func feedbackView(exercise: Exercise) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: isAnswerCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                .foregroundStyle(isAnswerCorrect ? BryqoTheme.leaf : BryqoTheme.sunlight)

            VStack(alignment: .leading, spacing: 4) {
                Text(isAnswerCorrect ? "Agora encaixou!" : "Esse bloco ainda não encaixou.")
                    .font(.headline)
                Text(exercise.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background((isAnswerCorrect ? BryqoTheme.leaf : BryqoTheme.sunlight).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
    }

    private func select(_ option: ExerciseOption) {
        guard let exercise = currentStep.exercise else {
            return
        }

        switch currentStep.kind {
        case .ordering:
            guard !selectedOptionIds.contains(option.id) else {
                return
            }

            selectedOptionIds.append(option.id)
            hasAnswered = selectedOptionIds.count == exercise.correctOptionIds.count
        default:
            selectedOptionIds = [option.id]
            hasAnswered = true
        }
    }

    private func advance() {
        if isLastStep {
            appState.completeLesson(lesson)
            dismiss()
            return
        }

        stepIndex += 1
        selectedOptionIds = []
        hasAnswered = false
    }

    private func optionIcon(_ option: ExerciseOption) -> String {
        if currentStep.kind == .ordering, let position = selectedOptionIds.firstIndex(of: option.id) {
            return "\(position + 1).circle.fill"
        }

        if hasAnswered, currentStep.exercise?.correctOptionIds.contains(option.id) == true {
            return "checkmark.circle.fill"
        }

        if selectedOptionIds.contains(option.id) {
            return "largecircle.fill.circle"
        }

        return "circle"
    }

    private func optionColor(_ option: ExerciseOption) -> Color {
        if hasAnswered, currentStep.exercise?.correctOptionIds.contains(option.id) == true {
            return BryqoTheme.leaf
        }

        if selectedOptionIds.contains(option.id) {
            return BryqoTheme.forest
        }

        return .secondary
    }

    private func optionBackground(_ option: ExerciseOption) -> Color {
        if hasAnswered, currentStep.exercise?.correctOptionIds.contains(option.id) == true {
            return BryqoTheme.leaf.opacity(0.16)
        }

        if selectedOptionIds.contains(option.id) {
            return BryqoTheme.river.opacity(0.12)
        }

        return Color.secondary.opacity(0.08)
    }

    private var stepLabel: String {
        switch currentStep.kind {
        case .story:
            return "Contexto"
        case .concept:
            return "Conceito"
        case .singleChoice:
            return "Escolha"
        case .trueFalse:
            return "Verdadeiro ou falso"
        case .ordering:
            return "Ordenar"
        case .summary:
            return "Resumo"
        }
    }

    private var stepIcon: String {
        switch currentStep.kind {
        case .story:
            return "book.pages.fill"
        case .concept:
            return "lightbulb.fill"
        case .singleChoice:
            return "checklist"
        case .trueFalse:
            return "questionmark.circle.fill"
        case .ordering:
            return "arrow.up.arrow.down"
        case .summary:
            return "seal.fill"
        }
    }
}
