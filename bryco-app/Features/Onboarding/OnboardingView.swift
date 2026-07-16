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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                valleyHero
                    .padding(.horizontal, -BryqoTheme.Spacing.xl)

                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                    Text("Bryqo")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(BryqoTheme.textPrimary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Construa seu conhecimento. Um bloco por vez.")
                        .font(.title2.bold())
                        .foregroundStyle(BryqoTheme.river)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Aprenda como computadores, redes e a internet realmente funcionam em lições curtas, práticas e guiadas por Brix.")
                        .font(.body)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(5)
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    private var profileStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    title: "Como podemos te chamar?",
                    subtitle: "Seu progresso fica salvo neste dispositivo."
                )

                Button {} label: {
                    Label("Continue with Apple", systemImage: "apple.logo")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
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
                    .font(.headline.weight(.semibold))
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
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    private var tracksStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                stepHeader(
                    title: "O que você vai aprender",
                    subtitle: "Três trilhas, desbloqueadas em ordem, cada uma com lições curtas e exercícios práticos."
                )

                VStack(spacing: BryqoTheme.Spacing.lg) {
                    ForEach(tracks) { track in
                        HStack(spacing: BryqoTheme.Spacing.lg) {
                            Image(systemName: track.icon)
                            .font(.title2)
                                .foregroundStyle(track.tint)
                            .frame(width: 58, height: 58)
                                .background(track.tint.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .layoutPriority(0)

                            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                                Text(track.title)
                                    .font(.headline.bold())
                                    .foregroundStyle(BryqoTheme.textPrimary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(track.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(BryqoTheme.textSecondary)
                                    .lineLimit(3)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineSpacing(3)
                            }
                            .layoutPriority(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bryqoCard()
                    }
                }
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
    }

    private var goalStep: some View {
        ScrollView(showsIndicators: false) {
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
                            HStack(spacing: BryqoTheme.Spacing.lg) {
                                VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xs) {
                                    Text(goal.title)
                                        .font(.headline.bold())
                                        .foregroundStyle(BryqoTheme.textPrimary)
                                    Text("\(goal.minutes) minutos por dia")
                                        .font(.subheadline)
                                        .foregroundStyle(BryqoTheme.textSecondary)
                                }
                                .layoutPriority(1)

                                Spacer()

                                if selectedDailyGoal == goal.minutes {
                                    Image(systemName: "checkmark.circle")
                                        .font(.title2)
                                        .foregroundStyle(BryqoTheme.river)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .bryqoCard(
                                padding: BryqoTheme.Spacing.lg,
                                fill: selectedDailyGoal == goal.minutes ? BryqoTheme.river.opacity(0.18) : BryqoTheme.surface,
                                border: selectedDailyGoal == goal.minutes ? BryqoTheme.river : BryqoTheme.border
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                BrixSpeechBubble(text: "Sem culpa por dias perdidos. O importante é voltar a construir.")
                    .padding(.top, BryqoTheme.Spacing.sm)
            }
            .padding(BryqoTheme.Spacing.xl)
            .padding(.bottom, BryqoTheme.Spacing.xl)
        }
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
        Image("OnboardingHero")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipped()
    }

    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            Text(title)
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(BryqoTheme.textPrimary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.body)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
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

#Preview {
    OnboardingView(appState: BryqoAppState())
}
