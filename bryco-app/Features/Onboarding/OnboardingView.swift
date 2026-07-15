import SwiftUI

struct OnboardingView: View {
    let appState: BryqoAppState

    @State private var step = 0
    @State private var displayName = ""
    @State private var selectedExperience = "Estou começando"
    @State private var selectedGoal = "Construir uma base"
    @State private var selectedDailyGoal = 10

    private let experiences = [
        "Nunca programei",
        "Estou começando",
        "Já estudo há algum tempo",
        "Já trabalho com desenvolvimento"
    ]

    private let goals = [
        "Construir uma base",
        "Melhorar nas entrevistas",
        "Preencher lacunas",
        "Revisar fundamentos"
    ]

    private let tracks = [
        TrackPreview(title: "Pensamento Computacional", subtitle: "Quebre problemas em partes e pense como um algoritmo.", icon: "safari", tint: BryqoTheme.river),
        TrackPreview(title: "Como Computadores Funcionam", subtitle: "Hardware, processamento e memória por trás de cada toque.", icon: "cpu", tint: BryqoTheme.primary),
        TrackPreview(title: "Internet e Redes", subtitle: "Como dispositivos se encontram e trocam informações.", icon: "wifi", tint: BryqoTheme.sun)
    ]

    private let dailyGoals = [
        DailyGoalOption(title: "Casual", minutes: 5),
        DailyGoalOption(title: "Regular", minutes: 10),
        DailyGoalOption(title: "Sério", minutes: 15),
        DailyGoalOption(title: "Intenso", minutes: 20)
    ]

    var body: some View {
        BryqoScreen {
            VStack(spacing: 0) {
                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    profileStep.tag(1)
                    tracksStep.tag(2)
                    goalStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomCTA
                    .padding(.horizontal, BryqoTheme.Spacing.xl)
                    .padding(.bottom, BryqoTheme.Spacing.xl)
            }
        }
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            valleyHero
                .padding(.horizontal, -BryqoTheme.Spacing.xl)

            Spacer(minLength: BryqoTheme.Spacing.lg)

            Text("Bryqo")
                .font(.system(size: 52, weight: .black))
                .foregroundStyle(BryqoTheme.textPrimary)

            Text("Construa seu conhecimento. Um bloco por vez.")
                .font(.title.bold())
                .foregroundStyle(BryqoTheme.river)

            Text("Aprenda como computadores, redes e a internet realmente funcionam em lições curtas, práticas e guiadas por Brix.")
                .font(.title3)
                .lineSpacing(5)
                .foregroundStyle(BryqoTheme.textSecondary)

            Spacer()
        }
        .padding(.horizontal, BryqoTheme.Spacing.xl)
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            stepHeader(
                title: "Como podemos te chamar?",
                subtitle: "Seu progresso fica salvo neste dispositivo."
            )

            Button {} label: {
                Label("Continue with Apple", systemImage: "apple.logo")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.button, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: BryqoTheme.Spacing.xl) {
                Rectangle().fill(BryqoTheme.border).frame(height: 1)
                Text("ou")
                    .font(.headline)
                    .foregroundStyle(BryqoTheme.textSecondary)
                Rectangle().fill(BryqoTheme.border).frame(height: 1)
            }

            TextField("Seu nome", text: $displayName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(BryqoTheme.textPrimary)
                .textInputAutocapitalization(.words)
                .padding(BryqoTheme.Spacing.xl)
                .background(BryqoTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                        .stroke(BryqoTheme.border, lineWidth: 1.5)
                }

            selectionGrid(title: "Experiência", options: experiences, selection: $selectedExperience)
            selectionGrid(title: "Objetivo", options: goals, selection: $selectedGoal)

            Spacer()
        }
        .padding(BryqoTheme.Spacing.xl)
    }

    private var tracksStep: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            stepHeader(
                title: "O que você vai aprender",
                subtitle: "Três trilhas, desbloqueadas em ordem, cada uma com lições curtas e exercícios práticos."
            )

            VStack(spacing: BryqoTheme.Spacing.lg) {
                ForEach(tracks) { track in
                    HStack(spacing: BryqoTheme.Spacing.xl) {
                        Image(systemName: track.icon)
                            .font(.title)
                            .foregroundStyle(track.tint)
                            .frame(width: 72, height: 72)
                            .background(track.tint.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                            Text(track.title)
                                .font(.title3.bold())
                                .foregroundStyle(BryqoTheme.textPrimary)
                            Text(track.subtitle)
                                .font(.body)
                                .foregroundStyle(BryqoTheme.textSecondary)
                                .lineSpacing(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bryqoCard()
                }
            }

            Spacer()
        }
        .padding(BryqoTheme.Spacing.xl)
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
            stepHeader(
                title: "Qual é a sua meta diária?",
                subtitle: "Você pode mudar isso a qualquer momento no seu perfil."
            )

            VStack(spacing: BryqoTheme.Spacing.lg) {
                ForEach(dailyGoals) { goal in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            selectedDailyGoal = goal.minutes
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                                Text(goal.title)
                                    .font(.title3.bold())
                                    .foregroundStyle(BryqoTheme.textPrimary)
                                Text("\(goal.minutes) minutos por dia")
                                    .font(.body)
                                    .foregroundStyle(BryqoTheme.textSecondary)
                            }

                            Spacer()

                            if selectedDailyGoal == goal.minutes {
                                Image(systemName: "checkmark.circle")
                                    .font(.largeTitle)
                                    .foregroundStyle(BryqoTheme.river)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .bryqoCard(
                            fill: selectedDailyGoal == goal.minutes ? BryqoTheme.river.opacity(0.18) : BryqoTheme.surface,
                            border: selectedDailyGoal == goal.minutes ? BryqoTheme.river : BryqoTheme.border
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            BrixSpeechBubble(text: "Sem culpa por dias perdidos. O importante é voltar a construir.")
                .padding(.top, BryqoTheme.Spacing.lg)

            Spacer()
        }
        .padding(BryqoTheme.Spacing.xl)
    }

    private var bottomCTA: some View {
        BryqoPrimaryButton(title: step == 0 ? "Começar" : step == 3 ? "Começar a construir" : "Continuar") {
            if step < 3 {
                withAnimation(.easeInOut(duration: 0.22)) {
                    step += 1
                }
            } else {
                appState.completeOnboarding(
                    displayName: displayName,
                    experience: selectedExperience,
                    goal: selectedGoal,
                    dailyGoalMinutes: selectedDailyGoal
                )
            }
        }
    }

    private var valleyHero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 0)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xF7C86A), BryqoTheme.river, BryqoTheme.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    ValleyIllustration()
                        .opacity(0.9)
                        .padding(.top, 28)
                }
                .frame(height: 340)

            BrixAvatar(size: 86)
                .padding(BryqoTheme.Spacing.xl)
        }
        .clipped()
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(title)
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(BryqoTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.title3)
                .lineSpacing(5)
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .padding(.top, BryqoTheme.Spacing.xxl)
    }

    private func selectionGrid(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
            Text(title)
                .font(.headline)
                .foregroundStyle(BryqoTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BryqoTheme.Spacing.md) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        Text(option)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selection.wrappedValue == option ? BryqoTheme.river : BryqoTheme.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .padding(.horizontal, BryqoTheme.Spacing.md)
                            .background(selection.wrappedValue == option ? BryqoTheme.river.opacity(0.14) : BryqoTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                                    .stroke(selection.wrappedValue == option ? BryqoTheme.river : BryqoTheme.border, lineWidth: 1.3)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TrackPreview: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
}

private struct DailyGoalOption: Identifiable {
    let id = UUID()
    let title: String
    let minutes: Int
}

private struct ValleyIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(BryqoTheme.primary.opacity(0.45))
                    .frame(width: CGFloat(180 + index * 44), height: CGFloat(90 + index * 18))
                    .offset(x: CGFloat(index * 46 - 70), y: CGFloat(index * 24 + 20))
            }

            Path { path in
                path.move(to: CGPoint(x: 0, y: 210))
                path.addCurve(to: CGPoint(x: 420, y: 190), control1: CGPoint(x: 120, y: 155), control2: CGPoint(x: 260, y: 245))
                path.addLine(to: CGPoint(x: 420, y: 340))
                path.addLine(to: CGPoint(x: 0, y: 340))
                path.closeSubpath()
            }
            .fill(BryqoTheme.river.opacity(0.65))

            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(BryqoTheme.wood)
                        .frame(width: 24, height: CGFloat(70 + index % 3 * 14))
                }
            }
            .offset(x: 75, y: 92)
        }
    }
}

#Preview {
    OnboardingView(appState: BryqoAppState())
}
