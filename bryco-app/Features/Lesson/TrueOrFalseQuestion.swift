import SwiftUI

struct TrueOrFalseQuestion: View {
    let exercise: Exercise
    let selectedOptionId: String?
    let hasAnswered: Bool
    let onSelect: (ExerciseOption) -> Void

    private var trueOption: ExerciseOption? { exercise.options.first { $0.id == "true" } }
    private var falseOption: ExerciseOption? { exercise.options.first { $0.id == "false" } }

    var body: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(exercise.prompt)
                .bryqoFont(19, weight: .bold, design: .rounded)
                .foregroundStyle(BryqoTheme.textPrimary)

            if let snippet = exercise.codeSnippet {
                CodeSnippetView(snippet: snippet)
            }

            HStack(spacing: BryqoTheme.Spacing.md) {
                if let opt = trueOption {
                    tfButton(opt, icon: "checkmark.circle", activeColor: BryqoTheme.success)
                }
                if let opt = falseOption {
                    tfButton(opt, icon: "xmark.circle", activeColor: BryqoTheme.error)
                }
            }
        }
        .bryqoCard()
    }

    private func tfButton(_ option: ExerciseOption, icon: String, activeColor: Color) -> some View {
        let isSelected = selectedOptionId == option.id
        let isCorrectOption = exercise.correctOptionIds.contains(option.id)

        let resolvedColor: Color = {
            if hasAnswered && isCorrectOption { return BryqoTheme.success }
            if hasAnswered && isSelected { return BryqoTheme.error }
            if isSelected { return activeColor }
            return BryqoTheme.border
        }()

        let bg: Color = {
            if hasAnswered && isCorrectOption { return BryqoTheme.success.opacity(0.12) }
            if hasAnswered && isSelected && !isCorrectOption { return BryqoTheme.error.opacity(0.10) }
            if isSelected { return activeColor.opacity(0.12) }
            return BryqoTheme.surface
        }()

        let iconName: String = {
            if hasAnswered && isCorrectOption { return "checkmark.circle.fill" }
            if hasAnswered && isSelected && !isCorrectOption { return "xmark.circle.fill" }
            return isSelected ? icon + ".fill" : icon
        }()

        return Button { onSelect(option) } label: {
            VStack(spacing: BryqoTheme.Spacing.sm) {
                Image(systemName: iconName)
                    .bryqoFont(26, relativeTo: .title2)
                    .foregroundStyle(resolvedColor)

                Text(option.text)
                    .bryqoFont(16, weight: .bold, design: .rounded)
                    .foregroundStyle(isSelected || (hasAnswered && isCorrectOption) ? resolvedColor : BryqoTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                    .stroke(resolvedColor, lineWidth: 2)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(hasAnswered)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isSelected)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: hasAnswered)
    }
}
