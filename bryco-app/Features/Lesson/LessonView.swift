import SwiftUI

enum LessonMode {
    case learn    // first-time completion — awards full XP, advances the trail
    case review   // spaced-repetition session on an already-completed lesson
}

struct LessonView: View {
    let appState: BryqoAppState
    let lesson: Lesson
    let mode: LessonMode

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LessonViewModel
    @State private var showCompletion = false
    @State private var xpFloatVisible = false
    init(appState: BryqoAppState, lesson: Lesson, mode: LessonMode = .learn) {
        self.appState = appState
        self.lesson = lesson
        self.mode = mode
        _viewModel = State(wrappedValue: LessonViewModel(lesson: lesson, initialHearts: appState.progress.hearts))
    }

    var body: some View {
        BryqoScreen {
            VStack(spacing: 0) {
                lessonTopBar

                if let trace = viewModel.currentStep.variableTrace {
                    // "Pense como a máquina" is a self-contained multi-prediction step; it owns its
                    // own scroll + bottom button and reports the outcome back to the lesson.
                    VariableTraceView(exercise: trace) { mistakes, correct in
                        viewModel.applyTraceResult(mistakes: mistakes, correct: correct)
                    }
                } else if let search = viewModel.currentStep.binarySearch {
                    BinarySearchPlaygroundView(exercise: search) { mistakes in
                        viewModel.applyTraceResult(mistakes: mistakes, correct: 1)
                    }
                } else {
                    standardStepContent
                    bottomBar
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            BryqoAnalytics.lessonStarted(lessonId: lesson.id)
        }
        // Haptics: reinforce correct/wrong answers (triggers only fire on change).
        .sensoryFeedback(.success, trigger: viewModel.xpFloatTrigger)
        .sensoryFeedback(.error, trigger: viewModel.shakeTrigger)
        // XP float badge overlay
        .overlay(alignment: .bottom) {
            xpFloatBadge
        }
        // Lesson completion screen overlay
        .overlay {
            if showCompletion {
                LessonCompletionView(
                    lesson: lesson,
                    xpEarned: viewModel.xpEarned,
                    correctCount: viewModel.correctCount,
                    totalQuestions: lesson.steps.filter { $0.exercise != nil }.count,
                    streakDays: appState.progress.streakDays
                ) {
                    switch mode {
                    case .learn:  appState.completeLesson(lesson, mistakeCount: viewModel.mistakeCount)
                    case .review: appState.completeReview(lesson, mistakeCount: viewModel.mistakeCount)
                    }
                    dismiss()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay {
            if viewModel.hearts == 0 && !viewModel.hasAnswered && !showCompletion {
                NoHeartsView {
                    dismiss()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.3), value: viewModel.hearts == 0 && !viewModel.hasAnswered)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: showCompletion)
        .onChange(of: viewModel.hearts) { old, new in
            if new < old { appState.loseHeart() }
        }
        .onChange(of: viewModel.isComplete) { _, complete in
            guard complete else { return }
            showCompletion = true
        }
        .onChange(of: viewModel.xpFloatTrigger) { _, _ in
            xpFloatVisible = true
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                xpFloatVisible = false
            }
        }
    }

    // MARK: - Standard Step Content

    private var standardStepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepBadge

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                    Text(viewModel.currentStep.title)
                        .bryqoFont(28, relativeTo: .largeTitle, weight: .black, design: .rounded)
                        .foregroundStyle(BryqoTheme.textPrimary)

                    if !viewModel.currentStep.body.isEmpty {
                        Text(viewModel.currentStep.body)
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(BryqoTheme.textSecondary)
                    }
                }
                .bryqoCard()

                if let exercise = viewModel.currentStep.exercise {
                    exerciseView(exercise)
                }
            }
            .padding(BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Top Bar

    private var lessonTopBar: some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .bryqoFont(14, weight: .bold)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .frame(width: 34, height: 34)
                    .background(BryqoTheme.border.opacity(0.5))
                    .clipShape(Circle())
                    .frame(width: 44, height: 44)   // HIG: 44pt minimum tap target
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sair da lição")

            LessonProgressBar(progress: viewModel.progress)
                .frame(height: 12)

            HeartsView(hearts: viewModel.hearts)
        }
        .padding(.horizontal, BryqoTheme.Spacing.xl)
        .padding(.vertical, BryqoTheme.Spacing.lg)
        .background(BryqoTheme.background)
    }

    // MARK: - Step Badge

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

    // MARK: - XP Float Badge

    private var xpFloatBadge: some View {
        Label("+10 XP", systemImage: "bolt.fill")
            .bryqoFont(16, weight: .black, design: .rounded)
            .foregroundStyle(BryqoTheme.sun)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(BryqoTheme.sun.opacity(0.15))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(BryqoTheme.sun.opacity(0.35), lineWidth: 1.5))
            .scaleEffect(xpFloatVisible ? 1.0 : 0.5)
            .opacity(xpFloatVisible ? 1.0 : 0.0)
            .offset(y: xpFloatVisible ? -140 : -100)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: xpFloatVisible)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            if viewModel.hasAnswered, let exercise = viewModel.currentStep.exercise {
                feedbackBanner(exercise: exercise)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                BryqoPrimaryButton(
                    title: verifyButtonTitle,
                    isDisabled: !viewModel.canVerify
                ) {
                    handlePrimaryAction()
                }
                .padding(BryqoTheme.Spacing.xl)
                .background(BryqoTheme.background)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.hasAnswered)
    }

    private var verifyButtonTitle: String {
        viewModel.currentStep.exercise == nil ? "CONTINUAR" : "VERIFICAR"
    }

    private func handlePrimaryAction() {
        if viewModel.currentStep.exercise != nil {
            viewModel.verify()
        } else {
            viewModel.advance()
        }
    }

    // MARK: - Feedback Banner

    private func feedbackBanner(exercise: Exercise) -> some View {
        let isCorrect = viewModel.isAnswerCorrect
        let accentColor = isCorrect ? BryqoTheme.success : BryqoTheme.error

        return VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack(alignment: .top, spacing: BryqoTheme.Spacing.lg) {
                BrixAvatar(size: 48)

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                    Text(isCorrect ? "Correto! 🎉" : "Ops! Quase lá. 🐛")
                        .bryqoFont(18, weight: .black, design: .rounded)
                        .foregroundStyle(accentColor)

                    Text(exercise.explanation)
                        .font(.subheadline)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            BryqoPrimaryButton(
                title: viewModel.isLastStep ? "CONCLUIR LIÇÃO" : "CONTINUAR",
                systemImage: viewModel.isLastStep ? "checkmark.seal.fill" : nil,
                color: accentColor,
                textColor: .white
            ) {
                viewModel.advance()
            }
        }
        .padding(BryqoTheme.Spacing.xl)
        .background(accentColor.opacity(0.08))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(accentColor)
                .frame(height: 2)
        }
    }

    // MARK: - Exercise View

    private func exerciseView(_ exercise: Exercise) -> some View {
        exerciseContent(exercise)
            .keyframeAnimator(
                initialValue: CGFloat(0),
                trigger: viewModel.shakeTrigger
            ) { view, offset in
                view.offset(x: offset)
            } keyframes: { _ in
                LinearKeyframe(8, duration: 0.07)
                LinearKeyframe(-8, duration: 0.07)
                LinearKeyframe(6, duration: 0.07)
                LinearKeyframe(-6, duration: 0.07)
                LinearKeyframe(3, duration: 0.07)
                LinearKeyframe(0, duration: 0.07)
            }
    }

    @ViewBuilder
    private func exerciseContent(_ exercise: Exercise) -> some View {
        switch viewModel.currentStep.kind {
        case .trueFalse:
            TrueOrFalseQuestion(
                exercise: exercise,
                selectedOptionId: viewModel.selectedOptionIds.first,
                hasAnswered: viewModel.hasAnswered
            ) { option in
                viewModel.selectOption(option)
                viewModel.verify()
            }

        case .codeCompletion:
            CodeCompletionQuestion(
                exercise: exercise,
                selectedOptionId: viewModel.selectedOptionIds.first,
                hasAnswered: viewModel.hasAnswered
            ) { option in
                withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                    viewModel.selectOption(option)
                }
            }

        default:
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                Text(exercise.prompt)
                    .bryqoFont(19, weight: .bold, design: .rounded)
                    .foregroundStyle(BryqoTheme.textPrimary)

                if let snippet = exercise.codeSnippet {
                    CodeSnippetView(snippet: snippet)
                }

                ForEach(exercise.options) { option in
                    OptionCard(
                        option: option,
                        isSelected: viewModel.selectedOptionIds.contains(option.id),
                        isCorrect: viewModel.hasAnswered && exercise.correctOptionIds.contains(option.id),
                        isWrong: viewModel.hasAnswered
                            && viewModel.selectedOptionIds.contains(option.id)
                            && !exercise.correctOptionIds.contains(option.id),
                        stepKind: viewModel.currentStep.kind,
                        selectionIndex: viewModel.selectedOptionIds.firstIndex(of: option.id)
                    ) {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.82)) {
                            viewModel.selectOption(option)
                        }
                    }
                    .disabled(viewModel.hasAnswered)
                }
            }
            .bryqoCard()
        }
    }

    // MARK: - Helpers

    private var stepLabel: String {
        switch viewModel.currentStep.kind {
        case .story: return "CONTEXTO"
        case .concept: return "CONCEITO"
        case .singleChoice: return "ESCOLHA"
        case .trueFalse: return "VERDADEIRO OU FALSO"
        case .ordering: return "ORDENAR"
        case .codeCompletion: return "COMPLETAR"
        case .variableTrace: return "PENSE COMO A MÁQUINA"
        case .binarySearch: return "VISUALIZAR"
        case .summary: return "RESUMO"
        }
    }

    private var stepIcon: String {
        switch viewModel.currentStep.kind {
        case .story: return "book.pages.fill"
        case .concept: return "lightbulb.fill"
        case .singleChoice: return "checklist"
        case .trueFalse: return "questionmark.circle.fill"
        case .ordering: return "arrow.up.arrow.down"
        case .codeCompletion: return "square.and.pencil"
        case .variableTrace: return "cpu.fill"
        case .binarySearch: return "chart.bar.xaxis"
        case .summary: return "seal.fill"
        }
    }
}

// MARK: - No Hearts View

private struct NoHeartsView: View {
    let onDismiss: () -> Void
    @State private var cardScale: CGFloat = 0.85
    @State private var cardOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: BryqoTheme.Spacing.xl) {
                BrixAvatar(size: 88)

                VStack(spacing: BryqoTheme.Spacing.sm) {
                    Text("Sem vidas! 💀")
                        .bryqoFont(28, relativeTo: .largeTitle, weight: .black, design: .rounded)
                        .foregroundStyle(BryqoTheme.error)

                    Text("Você ficou sem corações nessa lição.\nPratique outra para continuar.")
                        .font(.body)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                BryqoPrimaryButton(
                    title: "SAIR DA LIÇÃO",
                    systemImage: "xmark",
                    color: BryqoTheme.error,
                    textColor: .white,
                    action: onDismiss
                )
            }
            .padding(BryqoTheme.Spacing.xxl)
            .background(BryqoTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card + 4, style: .continuous))
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
    }
}

// MARK: - Option Card

private struct OptionCard: View {
    let option: ExerciseOption
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let stepKind: LessonStepKind
    let selectionIndex: Int?
    let onTap: () -> Void

    private var borderColor: Color {
        if isCorrect { return BryqoTheme.success }
        if isWrong { return BryqoTheme.error }
        if isSelected { return BryqoTheme.river }
        return BryqoTheme.border
    }

    private var backgroundColor: Color {
        if isCorrect { return BryqoTheme.success.opacity(0.12) }
        if isWrong { return BryqoTheme.error.opacity(0.10) }
        if isSelected { return BryqoTheme.river.opacity(0.12) }
        return BryqoTheme.surface
    }

    private var iconName: String {
        if stepKind == .ordering, let idx = selectionIndex {
            return "\(idx + 1).circle.fill"
        }
        if isCorrect { return "checkmark.circle.fill" }
        if isWrong { return "xmark.circle.fill" }
        if isSelected { return "largecircle.fill.circle" }
        return "circle"
    }

    private var iconColor: Color {
        if isCorrect { return BryqoTheme.success }
        if isWrong { return BryqoTheme.error }
        if isSelected { return BryqoTheme.river }
        return BryqoTheme.textSecondary
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BryqoTheme.Spacing.lg) {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                    .animation(.spring(response: 0.22, dampingFraction: 0.7), value: iconName)

                Text(option.text)
                    .bryqoFont(17, weight: .semibold, design: .rounded)
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(BryqoTheme.Spacing.lg)
            .background(backgroundColor)
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

// MARK: - Lesson Progress Bar

private struct LessonProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.pill, style: .continuous)
                    .fill(BryqoTheme.border)

                RoundedRectangle(cornerRadius: BryqoTheme.Radius.pill, style: .continuous)
                    .fill(BryqoTheme.success)
                    .frame(width: max(8, geometry.size.width * max(0, min(1, progress))))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
    }
}

// MARK: - Hearts View

private struct HeartsView: View {
    let hearts: Int
    private let maxHearts = 5
    @State private var lostIndex: Int? = nil
    @State private var lostScale: CGFloat = 1.0
    @State private var lostOpacity: Double = 1.0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<maxHearts, id: \.self) { index in
                ZStack {
                    // Outline heart (always visible underneath)
                    Image(systemName: "heart")
                        .bryqoFont(17)
                        .foregroundStyle(BryqoTheme.border)

                    // Filled heart (disappears with animation when lost)
                    if index < hearts || index == lostIndex {
                        Image(systemName: "heart.fill")
                            .bryqoFont(17)
                            .foregroundStyle(BryqoTheme.error)
                            .scaleEffect(index == lostIndex ? lostScale : 1.0)
                            .opacity(index == lostIndex ? lostOpacity : 1.0)
                    }
                }
            }
        }
        // VoiceOver reads a single "Vidas: N de 5" instead of ten separate heart images.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Vidas")
        .accessibilityValue("\(hearts) de \(maxHearts)")
        .onChange(of: hearts) { oldValue, newValue in
            guard newValue < oldValue else { return }
            lostIndex = newValue
            lostScale = 1.0
            lostOpacity = 1.0
            Task {
                // Phase 1: brief scale-up (impact feel)
                withAnimation(.spring(response: 0.15, dampingFraction: 0.4)) {
                    lostScale = 1.4
                }
                try? await Task.sleep(for: .milliseconds(150))
                // Phase 2: scale down + fade out
                withAnimation(.easeIn(duration: 0.3)) {
                    lostScale = 0.0
                    lostOpacity = 0.0
                }
                try? await Task.sleep(for: .milliseconds(380))
                lostIndex = nil
                lostScale = 1.0
                lostOpacity = 1.0
            }
        }
    }
}
