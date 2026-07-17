import SwiftUI

struct CodeCompletionQuestion: View {
    let exercise: Exercise
    let selectedOptionId: String?
    let hasAnswered: Bool
    let onSelect: (ExerciseOption) -> Void

    private var filledCode: String? {
        guard let snippet = exercise.codeSnippet else { return nil }
        if let id = selectedOptionId, let text = exercise.options.first(where: { $0.id == id })?.text {
            return snippet.code.replacingOccurrences(of: "___", with: text)
        }
        return snippet.code
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(exercise.prompt)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(BryqoTheme.textPrimary)

            // Live-filled code snippet
            if let code = filledCode, let snippet = exercise.codeSnippet {
                CodeSnippetView(snippet: CodeSnippet(code: code, language: snippet.language))
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedOptionId)
            }

            // Option chips
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 88, maximum: 220), spacing: BryqoTheme.Spacing.sm)],
                spacing: BryqoTheme.Spacing.sm
            ) {
                ForEach(exercise.options) { option in
                    CompletionChip(
                        text: option.text,
                        isSelected: selectedOptionId == option.id,
                        isCorrect: hasAnswered && exercise.correctOptionIds.contains(option.id),
                        isWrong: hasAnswered
                            && selectedOptionId == option.id
                            && !exercise.correctOptionIds.contains(option.id),
                        onTap: { onSelect(option) }
                    )
                    .disabled(hasAnswered)
                }
            }
        }
        .bryqoCard()
    }
}

// MARK: - Completion Chip

private struct CompletionChip: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let onTap: () -> Void

    private var borderColor: Color {
        if isCorrect { return BryqoTheme.success }
        if isWrong  { return BryqoTheme.error }
        if isSelected { return BryqoTheme.river }
        return BryqoTheme.border
    }

    private var bg: Color {
        if isCorrect { return BryqoTheme.success.opacity(0.14) }
        if isWrong   { return BryqoTheme.error.opacity(0.12) }
        if isSelected { return BryqoTheme.river }
        return BryqoTheme.surface
    }

    private var textColor: Color {
        if isSelected && !isCorrect && !isWrong { return .white }
        if isCorrect { return BryqoTheme.success }
        if isWrong   { return BryqoTheme.error }
        return BryqoTheme.textPrimary
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .padding(.horizontal, BryqoTheme.Spacing.lg)
                .padding(.vertical, BryqoTheme.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                        .stroke(borderColor, lineWidth: 2)
                }
        }
        .buttonStyle(PressScaleButtonStyle())
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isSelected)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isCorrect)
        .animation(.spring(response: 0.22, dampingFraction: 0.82), value: isWrong)
    }
}
