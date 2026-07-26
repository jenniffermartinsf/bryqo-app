import SwiftUI

/// "Pense como a máquina" — the learner steps through pseudocode predicting the running state.
/// Self-contained: owns its scroll + bottom button and reports the outcome to the lesson.
struct VariableTraceView: View {
    let exercise: VariableTraceExercise
    let onFinished: (_ mistakes: Int, _ correct: Int) -> Void

    @State private var vm: VariableTraceViewModel

    init(exercise: VariableTraceExercise, onFinished: @escaping (Int, Int) -> Void) {
        self.exercise = exercise
        self.onFinished = onFinished
        _vm = State(wrappedValue: VariableTraceViewModel(exercise: exercise))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                    badge
                    Text(exercise.intro)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(BryqoTheme.textSecondary)

                    codeBlock
                    if !vm.revealed.isEmpty { statePanel }
                    questionCard
                }
                .padding(BryqoTheme.Spacing.xl)
            }
            bottomButton
        }
        .sensoryFeedback(.error, trigger: vm.shakeTrigger)
        .sensoryFeedback(.success, trigger: vm.correctCount)
    }

    // MARK: Badge

    private var badge: some View {
        Label("PENSE COMO A MÁQUINA", systemImage: "cpu.fill")
            .font(.subheadline.weight(.black))
            .tracking(1.1)
            .foregroundStyle(BryqoTheme.river)
            .padding(.horizontal, BryqoTheme.Spacing.lg)
            .padding(.vertical, BryqoTheme.Spacing.md)
            .background(BryqoTheme.river.opacity(0.14))
            .clipShape(Capsule())
    }

    // MARK: Code

    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(exercise.codeLines.enumerated()), id: \.offset) { index, line in
                let isActive = index == vm.currentStep.highlightedLine
                HStack(spacing: BryqoTheme.Spacing.md) {
                    Image(systemName: isActive ? "arrowtriangle.right.fill" : "circle.fill")
                        .font(.system(size: isActive ? 11 : 4))
                        .foregroundStyle(isActive ? BryqoTheme.river : BryqoTheme.textSecondary.opacity(0.3))
                        .frame(width: 14)
                    Text(line)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundStyle(isActive ? BryqoTheme.textPrimary : BryqoTheme.textSecondary)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, BryqoTheme.Spacing.md)
                .background(isActive ? BryqoTheme.river.opacity(0.12) : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(BryqoTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BryqoTheme.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(BryqoTheme.border, lineWidth: 1.5)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: vm.stepIndex)
    }

    // MARK: Running state table

    private var statePanel: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
            Text("ESTADO DA MÁQUINA")
                .font(.caption2.weight(.black))
                .tracking(1)
                .foregroundStyle(BryqoTheme.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BryqoTheme.Spacing.sm) {
                    ForEach(vm.revealed) { item in
                        HStack(spacing: 4) {
                            Text(item.variable).fontWeight(.bold)
                            Text("=").foregroundStyle(BryqoTheme.textSecondary)
                            Text(item.value).fontWeight(.black).foregroundStyle(BryqoTheme.primary)
                        }
                        .font(.system(.footnote, design: .monospaced))
                        .padding(.horizontal, BryqoTheme.Spacing.md)
                        .padding(.vertical, BryqoTheme.Spacing.sm)
                        .background(BryqoTheme.primary.opacity(0.10))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: Question

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(vm.currentStep.prompt)
                .font(.headline.bold())
                .foregroundStyle(BryqoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: BryqoTheme.Spacing.md) {
                ForEach(vm.currentStep.options, id: \.self) { option in
                    optionButton(option)
                }
            }

            if vm.hasAnswered {
                feedback
            }
        }
        .bryqoCard()
        .animation(.spring(response: 0.3, dampingFraction: 0.82), value: vm.hasAnswered)
    }

    private func optionButton(_ option: String) -> some View {
        let isSelected = vm.selectedAnswer == option
        let isCorrect = option == vm.currentStep.correctAnswer
        let showResult = vm.hasAnswered && (isSelected || isCorrect)

        let color: Color = {
            if vm.hasAnswered && isCorrect { return BryqoTheme.success }
            if vm.hasAnswered && isSelected { return BryqoTheme.error }
            if isSelected { return BryqoTheme.river }
            return BryqoTheme.border
        }()

        return Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.85)) { vm.select(option) }
        } label: {
            HStack {
                Text(option)
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .foregroundStyle(showResult ? color : BryqoTheme.textPrimary)
                Spacer()
                if showResult {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(color)
                }
            }
            .padding(BryqoTheme.Spacing.lg)
            .background(color.opacity(vm.hasAnswered && (isCorrect || isSelected) ? 0.10 : (isSelected ? 0.12 : 0)))
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                    .stroke(color, lineWidth: 1.5)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(vm.hasAnswered)
    }

    private var feedback: some View {
        HStack(alignment: .top, spacing: BryqoTheme.Spacing.md) {
            Image(systemName: vm.isAnswerCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                .foregroundStyle(vm.isAnswerCorrect ? BryqoTheme.success : BryqoTheme.sun)
            Text(vm.currentStep.explanation)
                .font(.subheadline)
                .foregroundStyle(BryqoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(BryqoTheme.Spacing.md)
        .background((vm.isAnswerCorrect ? BryqoTheme.success : BryqoTheme.sun).opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: Bottom button

    private var bottomButton: some View {
        BryqoPrimaryButton(
            title: vm.hasAnswered ? (vm.isLastStep ? "CONCLUIR" : "PRÓXIMA LINHA") : "VERIFICAR",
            isDisabled: !vm.hasAnswered && !vm.canVerify,
            color: vm.hasAnswered ? BryqoTheme.primary : BryqoTheme.river
        ) {
            if vm.hasAnswered {
                if vm.isLastStep {
                    onFinished(vm.mistakeCount, vm.correctCount)
                } else {
                    vm.advance()
                }
            } else {
                vm.verify()
            }
        }
        .padding(BryqoTheme.Spacing.xl)
        .background(BryqoTheme.background)
    }
}
