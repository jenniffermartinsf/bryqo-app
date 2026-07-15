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
        guard let exercise = currentStep.exercise else { return true }
        return selectedOptionIds == exercise.correctOptionIds
    }

    var body: some View {
        BryqoScreen {
            VStack(spacing: 0) {
                progressHeader

                ScrollView {
                    VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                        stepBadge

                        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                            Text(currentStep.title)
                                .font(.system(size: 30, weight: .black))
                                .foregroundStyle(BryqoTheme.textPrimary)

                            if !currentStep.body.isEmpty {
                                Text(currentStep.body)
                                    .font(.body)
                                    .lineSpacing(5)
                                    .foregroundStyle(BryqoTheme.textSecondary)
                            }
                        }
                        .bryqoCard()

                        if let exercise = currentStep.exercise {
                            exerciseView(exercise)
                        }
                    }
                    .padding(BryqoTheme.Spacing.xl)
                }

                bottomBar
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var progressHeader: some View {
        VStack(spacing: BryqoTheme.Spacing.md) {
            ProgressView(value: Double(stepIndex + 1), total: Double(lesson.steps.count))
                .tint(BryqoTheme.river)
                .background(Color.white.opacity(0.05))

            HStack {
                BryqoStatPill(value: "\(lesson.xpReward) XP", icon: "bolt.fill", tint: BryqoTheme.sun)
                Spacer()
                Text("Etapa \(stepIndex + 1) de \(lesson.steps.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
        }
        .padding(BryqoTheme.Spacing.xl)
        .background(BryqoTheme.background)
    }

    private var stepBadge: some View {
        Label(stepLabel, systemImage: stepIcon)
            .font(.subheadline.weight(.black))
            .tracking(1.2)
            .foregroundStyle(BryqoTheme.river)
            .padding(.horizontal, BryqoTheme.Spacing.lg)
            .padding(.vertical, BryqoTheme.Spacing.md)
            .background(BryqoTheme.river.opacity(0.14))
            .clipShape(Capsule())
    }

    private var bottomBar: some View {
        VStack(spacing: BryqoTheme.Spacing.md) {
            if hasAnswered, let exercise = currentStep.exercise {
                feedbackView(exercise: exercise)
            }

            BryqoPrimaryButton(
                title: isLastStep ? "Concluir lição" : "Continuar",
                systemImage: isLastStep ? "checkmark.seal.fill" : "arrow.right",
                isDisabled: currentStep.exercise != nil && !hasAnswered
            ) {
                advance()
            }
        }
        .padding(BryqoTheme.Spacing.xl)
        .background(BryqoTheme.background)
    }

    private func exerciseView(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(exercise.prompt)
                .font(.headline.bold())
                .foregroundStyle(BryqoTheme.textPrimary)

            ForEach(exercise.options) { option in
                Button {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                        select(option)
                    }
                } label: {
                    HStack(alignment: .center, spacing: BryqoTheme.Spacing.lg) {
                        Image(systemName: optionIcon(option))
                            .font(.headline)
                            .foregroundStyle(optionColor(option))

                        Text(option.text)
                            .font(.headline)
                            .foregroundStyle(BryqoTheme.textPrimary)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(BryqoTheme.Spacing.lg)
                    .background(optionBackground(option))
                    .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                            .stroke(optionColor(option).opacity(selectedOptionIds.contains(option.id) || hasAnswered ? 0.8 : 0.18), lineWidth: 1.5)
                    }
                }
                .buttonStyle(.plain)
                .disabled(hasAnswered)
            }
        }
        .bryqoCard()
    }

    private func feedbackView(exercise: Exercise) -> some View {
        HStack(alignment: .center, spacing: BryqoTheme.Spacing.lg) {
            BrixAvatar(size: 42)

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                Text(isAnswerCorrect ? "Agora encaixou!" : "Vamos olhar por outro ângulo.")
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textPrimary)
                Text(exercise.explanation)
                    .font(.subheadline)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BryqoTheme.Spacing.lg)
        .background((isAnswerCorrect ? BryqoTheme.success : BryqoTheme.sun).opacity(0.13))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                .stroke((isAnswerCorrect ? BryqoTheme.success : BryqoTheme.sun).opacity(0.22), lineWidth: 1)
        }
    }

    private func select(_ option: ExerciseOption) {
        guard let exercise = currentStep.exercise else { return }

        switch currentStep.kind {
        case .ordering:
            guard !selectedOptionIds.contains(option.id) else { return }
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

        withAnimation(.easeInOut(duration: 0.22)) {
            stepIndex += 1
            selectedOptionIds = []
            hasAnswered = false
        }
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
            return BryqoTheme.success
        }

        if selectedOptionIds.contains(option.id) {
            return BryqoTheme.river
        }

        return BryqoTheme.textSecondary
    }

    private func optionBackground(_ option: ExerciseOption) -> Color {
        if hasAnswered, currentStep.exercise?.correctOptionIds.contains(option.id) == true {
            return BryqoTheme.success.opacity(0.14)
        }

        if selectedOptionIds.contains(option.id) {
            return BryqoTheme.river.opacity(0.14)
        }

        return Color.white.opacity(0.04)
    }

    private var stepLabel: String {
        switch currentStep.kind {
        case .story:
            return "CONTEXTO"
        case .concept:
            return "CONCEITO"
        case .singleChoice:
            return "ESCOLHA"
        case .trueFalse:
            return "VERDADEIRO OU FALSO"
        case .ordering:
            return "ORDENAR"
        case .summary:
            return "RESUMO"
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
