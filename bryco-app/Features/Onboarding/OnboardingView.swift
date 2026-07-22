import SwiftUI

struct OnboardingView: View {
    let appState: BryqoAppState

    @State private var step = 0
    @State private var goingForward = true
    @State private var displayName = ""
    @State private var didAttemptContinue = false
    @State private var selectedExperience = ""
    @State private var selectedGoal = ""
    @State private var selectedDailyGoal = 10
    // Welcome screen animations
    @State private var mascotFloat: CGFloat = 0
    @State private var welcomeAppeared = false
    @State private var quizAnswer: String? = nil
    @State private var quizChecked = false

    private let experiences: [(icon: String, title: String, subtitle: String)] = [
        ("🌱", "Nunca programei", "Começando do zero, do jeito certo"),
        ("📖", "Estou aprendendo", "Já vi algo, mas quero uma base sólida"),
        ("💻", "Sei o básico", "Quero preencher lacunas e aprofundar"),
        ("🚀", "Trabalho com dev", "Revisando fundamentos")
    ]

    private let goals: [(icon: String, title: String, subtitle: String)] = [
        ("🏗️", "Construir uma base sólida", "Aprender do zero de forma consistente"),
        ("🎯", "Me preparar para entrevistas", "Algoritmos, lógica e estruturas de dados"),
        ("🔍", "Preencher lacunas", "Reforçar conceitos que ficaram soltos"),
        ("🔄", "Revisar fundamentos", "Consolidar o que já sei")
    ]

    private let dailyGoals: [DailyGoalOption] = [
        DailyGoalOption(title: "Casual", subtitle: "Aprendo quando tenho tempo", minutes: 5),
        DailyGoalOption(title: "Regular", subtitle: "Um hábito leve todo dia", minutes: 10),
        DailyGoalOption(title: "Sério", subtitle: "Comprometido com o progresso", minutes: 15),
        DailyGoalOption(title: "Intenso", subtitle: "Foco total no aprendizado", minutes: 20)
    ]

    private let quizOptions = ["Um Algoritmo", "Um Vírus", "Uma RAM", "Um Pixel"]
    private let quizCorrect = "Um Algoritmo"

    var body: some View {
        BryqoScreen {
            VStack(spacing: 0) {
                if step > 0 && step < 7 {
                    navBar
                        .padding(.horizontal, BryqoTheme.Spacing.xl)
                        .padding(.top, BryqoTheme.Spacing.md)
                        .padding(.bottom, BryqoTheme.Spacing.sm)
                }

                ZStack {
                    currentStepView
                        .id(step)
                        .transition(.asymmetric(
                            insertion: .move(edge: goingForward ? .trailing : .leading),
                            removal: .move(edge: goingForward ? .leading : .trailing)
                        ))
                }
                .clipped()
                .animation(.spring(response: 0.38, dampingFraction: 0.88), value: step)

                bottomCTA
                    .padding(.horizontal, BryqoTheme.Spacing.xl)
                    .padding(.bottom, BryqoTheme.Spacing.xl)
            }
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch step {
        case 0:  welcomeStep
        case 1:  featuresStep
        case 2:  nameStep
        case 3:  experienceStep
        case 4:  goalStep
        case 5:  miniQuizStep
        case 6:  dailyGoalStep
        default: allSetStep
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            Button { navigate(forward: false) } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(BryqoTheme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 6) {
                ForEach(1..<7, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? BryqoTheme.primary : BryqoTheme.border)
                        .frame(width: i == step ? 22 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.72), value: step)
                }
            }
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo-v3 flutuando, centralizada
            Image("BryqoLogoV3")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, BryqoTheme.Spacing.xl)
                .offset(y: mascotFloat)
                .scaleEffect(welcomeAppeared ? 1.0 : 0.78)
                .opacity(welcomeAppeared ? 1.0 : 0)
                .onAppear {
                    withAnimation(.spring(response: 0.65, dampingFraction: 0.7)) {
                        welcomeAppeared = true
                    }
                    withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                        mascotFloat = -24
                    }
                }

            // Título + subtítulo logo abaixo, com 32pt de separação da logo
            VStack(spacing: 12) {
                Text("Aprenda a pensar como programador.")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Olá, eu sou o Brix! Vamos aprender os fundamentos da programação construindo, juntos, um vale inteiro.")
                    .font(.body)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .padding(.top, 32)
            .opacity(welcomeAppeared ? 1.0 : 0)
            .animation(.easeOut(duration: 0.35).delay(0.2), value: welcomeAppeared)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Step 1: Features

    private var featuresStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                    Text("Fundamentos antes\nde frameworks.")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)

                    Text("Aqui você aprende o que realmente fica.")
                        .font(.body)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .lineSpacing(4)
                }

                VStack(spacing: BryqoTheme.Spacing.md) {
                    featureCard(
                        icon: "bolt.fill",
                        tint: BryqoTheme.river,
                        title: "Lições de 5 minutos",
                        subtitle: "Aprenda um conceito por vez, no seu ritmo, sem pressão."
                    )
                    featureCard(
                        icon: "star.fill",
                        tint: BryqoTheme.primary,
                        title: "XP, streaks e conquistas",
                        subtitle: "Cada lição te faz crescer e você vê o progresso acontecer."
                    )
                    featureCard(
                        icon: "checkmark.seal.fill",
                        tint: BryqoTheme.sun,
                        title: "Do zero ao sólido, sem enrolação",
                        subtitle: "Fundamentos reais que ficam para sempre na sua cabeça."
                    )
                }
            }
            .padding(.horizontal, BryqoTheme.Spacing.xl)

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func featureCard(icon: String, tint: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 46, height: 46)
                .background(tint.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(BryqoTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)

            Spacer()
        }
        .padding(BryqoTheme.Spacing.lg)
        .background(BryqoTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(BryqoTheme.border, lineWidth: 1.5)
        }
    }

    // MARK: - Step 2: Name

    private var nameStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    icon: "person.fill",
                    title: "Como podemos\nte chamar?",
                    subtitle: "Seu progresso fica salvo neste dispositivo."
                )

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                    TextField("Seu nome", text: $displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .textInputAutocapitalization(.words)
                        .padding(BryqoTheme.Spacing.xl)
                        .background(BryqoTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                                .strokeBorder(
                                    didAttemptContinue && !isNameValid ? BryqoTheme.error : BryqoTheme.border,
                                    lineWidth: 1.5
                                )
                        }
                        .onChange(of: displayName) { _, _ in didAttemptContinue = false }

                    if didAttemptContinue && !isNameValid {
                        Label("Digite seu nome para continuar.", systemImage: "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BryqoTheme.error)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                BrixSpeechBubble(text: "Pode ser seu apelido! Eu mesmo prefiro Brix a Brixiliano Algoritmão.")
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Step 2: Experience

    private var experienceStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    icon: "chart.bar.fill",
                    title: "Qual é sua\nexperiência?",
                    subtitle: "Vamos adaptar o ritmo para você."
                )

                VStack(spacing: BryqoTheme.Spacing.md) {
                    ForEach(experiences, id: \.title) { exp in
                        selectionRow(
                            icon: exp.icon, title: exp.title, subtitle: exp.subtitle,
                            isSelected: selectedExperience == exp.title
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                selectedExperience = exp.title
                            }
                        }
                    }
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Step 3: Goal

    private var goalStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    icon: "target",
                    title: "Qual é o seu\nobjetivo?",
                    subtitle: "Isso ajuda a personalizar sua trilha."
                )

                VStack(spacing: BryqoTheme.Spacing.md) {
                    ForEach(goals, id: \.title) { goal in
                        selectionRow(
                            icon: goal.icon, title: goal.title, subtitle: goal.subtitle,
                            isSelected: selectedGoal == goal.title
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                selectedGoal = goal.title
                            }
                        }
                    }
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Step 4: Mini Quiz

    private var miniQuizStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    icon: "sparkles",
                    title: "Um gostinho\ndo que vem por aí",
                    subtitle: "Não tem nota, somente um aquecimento."
                )

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                    Text("Você está ensinando um robô a fazer um sanduíche, passo a passo. O que você está criando?")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)

                    VStack(spacing: BryqoTheme.Spacing.md) {
                        ForEach(quizOptions, id: \.self) { option in
                            quizOptionButton(option)
                        }
                    }
                }
                .padding(BryqoTheme.Spacing.lg)
                .background(BryqoTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                        .strokeBorder(BryqoTheme.border, lineWidth: 1.5)
                }

                if quizChecked, let ans = quizAnswer {
                    quizFeedback(isCorrect: ans == quizCorrect)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: quizChecked)
        }
    }

    private func quizOptionButton(_ option: String) -> some View {
        let isSelected = quizAnswer == option
        let isCorrect = option == quizCorrect
        let showResult = quizChecked && isSelected

        return Button {
            guard !quizChecked else { return }
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                quizAnswer = option
                quizChecked = true
            }
        } label: {
            HStack(spacing: BryqoTheme.Spacing.md) {
                Text(option)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(
                        showResult ? (isCorrect ? BryqoTheme.success : BryqoTheme.error)
                            : (isSelected ? BryqoTheme.river : BryqoTheme.textPrimary)
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if showResult {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? BryqoTheme.success : BryqoTheme.error)
                }
            }
            .padding(BryqoTheme.Spacing.lg)
            .background(
                showResult ? (isCorrect ? BryqoTheme.success.opacity(0.12) : BryqoTheme.error.opacity(0.12))
                    : (isSelected ? BryqoTheme.river.opacity(0.14) : BryqoTheme.background)
            )
            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                    .strokeBorder(
                        showResult ? (isCorrect ? BryqoTheme.success : BryqoTheme.error)
                            : (isSelected ? BryqoTheme.river : BryqoTheme.border),
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private func quizFeedback(isCorrect: Bool) -> some View {
        HStack(alignment: .top, spacing: BryqoTheme.Spacing.md) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                .font(.title3)
                .foregroundStyle(isCorrect ? BryqoTheme.success : BryqoTheme.sun)

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                Text(isCorrect ? "Exatamente!" : "Quase lá!")
                    .font(.headline.bold())
                    .foregroundStyle(isCorrect ? BryqoTheme.success : BryqoTheme.sun)

                Text(
                    isCorrect
                        ? "Um algoritmo é uma sequência de passos para resolver um problema. Você já pensa como dev!"
                        : "Um algoritmo é uma sequência de instruções — como uma receita passo a passo. No app você vai criar os seus."
                )
                .font(.subheadline)
                .foregroundStyle(BryqoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
            }
            .layoutPriority(1)
        }
        .padding(BryqoTheme.Spacing.lg)
        .background((isCorrect ? BryqoTheme.success : BryqoTheme.sun).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                .strokeBorder((isCorrect ? BryqoTheme.success : BryqoTheme.sun).opacity(0.35), lineWidth: 1.5)
        }
    }

    // MARK: - Step 5: Daily Goal

    private var dailyGoalStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    icon: "calendar.badge.clock",
                    title: "Qual é a sua\nmeta diária?",
                    subtitle: "Você pode mudar isso a qualquer momento."
                )

                VStack(spacing: BryqoTheme.Spacing.md) {
                    ForEach(dailyGoals) { goal in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                selectedDailyGoal = goal.minutes
                            }
                        } label: {
                            HStack(spacing: BryqoTheme.Spacing.lg) {
                                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                                    Text(goal.title)
                                        .font(.headline.bold())
                                        .foregroundStyle(BryqoTheme.textPrimary)
                                    Text(goal.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(BryqoTheme.textSecondary)
                                }
                                .layoutPriority(1)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(goal.minutes) min")
                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                        .foregroundStyle(selectedDailyGoal == goal.minutes ? BryqoTheme.river : BryqoTheme.textSecondary)
                                    Text("+\(BryqoAppState.xpGoal(for: goal.minutes)) XP/dia")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(BryqoTheme.textSecondary.opacity(0.7))
                                }

                                if selectedDailyGoal == goal.minutes {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(BryqoTheme.river)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .bryqoCard(
                                padding: BryqoTheme.Spacing.lg,
                                fill: selectedDailyGoal == goal.minutes ? BryqoTheme.river.opacity(0.12) : BryqoTheme.surface,
                                border: selectedDailyGoal == goal.minutes ? BryqoTheme.river : BryqoTheme.border
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: selectedDailyGoal)
                    }
                }

                BrixSpeechBubble(text: "Sem culpa por dias perdidos. O importante é voltar a construir.")
                    .padding(.top, BryqoTheme.Spacing.sm)
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Step 6: All Set

    private var allSetStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: BryqoTheme.Spacing.xl) {
                Image("BrixFeliz")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, BryqoTheme.Spacing.xxxl)

                VStack(spacing: BryqoTheme.Spacing.sm) {
                    Text("Tudo pronto,")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text(firstName)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(BryqoTheme.primary)
                    Text("🎉")
                        .font(.system(size: 44))
                }
                .multilineTextAlignment(.center)

                VStack(spacing: BryqoTheme.Spacing.md) {
                    summaryRow(
                        icon: "chart.bar.fill",
                        label: selectedExperience.isEmpty ? "Iniciante" : selectedExperience,
                        tint: BryqoTheme.river
                    )
                    summaryRow(
                        icon: "target",
                        label: selectedGoal.isEmpty ? "Construir uma base" : selectedGoal,
                        tint: BryqoTheme.primary
                    )
                    summaryRow(
                        icon: "calendar.badge.clock",
                        label: "\(selectedDailyGoal) minutos por dia",
                        tint: BryqoTheme.sun
                    )
                }
                .padding(.horizontal, BryqoTheme.Spacing.sm)

                BrixSpeechBubble(text: "Cada lição te deixa mais perto de pensar como engenheiro. Bora começar!")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        let (title, disabled): (String, Bool) = {
            switch step {
            case 0:  return ("Vamos construir", false)
            case 1:  return ("Continuar", false)
            case 2:  return ("Continuar", false)
            case 3:  return (selectedExperience.isEmpty ? "Selecione seu nível" : "Continuar", selectedExperience.isEmpty)
            case 4:  return (selectedGoal.isEmpty ? "Selecione seu objetivo" : "Continuar", selectedGoal.isEmpty)
            case 5:  return (quizChecked ? "Continuar" : "Responda para continuar", !quizChecked)
            case 6:  return ("Continuar", false)
            default: return ("Começar a construir", false)
            }
        }()

        return BryqoPrimaryButton(
            title: title,
            isDisabled: disabled,
            color: step == 7 ? BryqoTheme.primary : BryqoTheme.river
        ) {
            advance()
        }
    }

    // MARK: - Logic

    private var firstName: String {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "construtor" : (name.components(separatedBy: " ").first ?? name)
    }

    private var isNameValid: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func advance() {
        if step == 2 && !isNameValid {
            withAnimation(.easeOut(duration: 0.18)) { didAttemptContinue = true }
            return
        }
        if step < 7 {
            navigate(forward: true)
        } else {
            appState.completeOnboarding(
                displayName: displayName,
                experience: selectedExperience.isEmpty ? "Iniciante" : selectedExperience,
                goal: selectedGoal.isEmpty ? "Construir uma base" : selectedGoal,
                dailyGoalMinutes: selectedDailyGoal
            )
        }
    }

    private func navigate(forward: Bool) {
        goingForward = forward
        withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
            step = forward ? step + 1 : step - 1
        }
    }

    // MARK: - Reusable Views

    private func featurePill(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.15))
                .clipShape(Circle())

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, BryqoTheme.Spacing.lg)
        .padding(.vertical, BryqoTheme.Spacing.md)
        .background(BryqoTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
    }

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(BryqoTheme.primary)
                .padding(.top, BryqoTheme.Spacing.lg)

            Text(title)
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(BryqoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(BryqoTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func selectionRow(icon: String, title: String, subtitle: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: BryqoTheme.Spacing.lg) {
                Text(icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? BryqoTheme.primary.opacity(0.14) : BryqoTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(BryqoTheme.primary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .bryqoCard(
                padding: BryqoTheme.Spacing.md,
                fill: isSelected ? BryqoTheme.primary.opacity(0.07) : BryqoTheme.surface,
                border: isSelected ? BryqoTheme.primary : BryqoTheme.border
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
    }

    private func summaryRow(icon: String, label: String, tint: Color) -> some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.body.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.14))
                .clipShape(Circle())

            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, BryqoTheme.Spacing.lg)
        .padding(.vertical, BryqoTheme.Spacing.md)
        .background(tint.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                .strokeBorder(tint.opacity(0.25), lineWidth: 1.5)
        }
    }
}

private struct DailyGoalOption: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let minutes: Int
}

#Preview {
    OnboardingView(appState: BryqoAppState())
}
