import SwiftUI

struct OnboardingView: View {
    let appState: BryqoAppState

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

    private let dailyGoals = [5, 10, 15]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    selectionSection(
                        title: "Qual é sua experiência?",
                        options: experiences,
                        selection: $selectedExperience
                    )

                    selectionSection(
                        title: "O que você quer construir primeiro?",
                        options: goals,
                        selection: $selectedGoal
                    )

                    dailyGoalSection

                    Button {
                        appState.completeOnboarding(
                            experience: selectedExperience,
                            goal: selectedGoal,
                            dailyGoalMinutes: selectedDailyGoal
                        )
                    } label: {
                        Label("Começar a construir", systemImage: "hammer.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .background(BryqoTheme.softBackground.ignoresSafeArea())
            .navigationTitle("Bryqo")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Construa seu conhecimento. Um bloco por vez.")
                .font(.largeTitle.bold())
                .foregroundStyle(BryqoTheme.forest)

            Text("Brix vai acompanhar sua jornada pelos fundamentos da computação com lições curtas, práticas e sem culpa por errar.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }

    private var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meta diária")
                .font(.headline)

            HStack {
                ForEach(dailyGoals, id: \.self) { minutes in
                    Button {
                        selectedDailyGoal = minutes
                    } label: {
                        Text("\(minutes) min")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedDailyGoal == minutes ? BryqoTheme.forest : BryqoTheme.stone)
                    .accessibilityLabel("\(minutes) minutos por dia")
                }
            }
        }
        .bryqoCard()
    }

    private func selectionSection(
        title: String,
        options: [String],
        selection: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        HStack {
                            Text(option)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: selection.wrappedValue == option ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selection.wrappedValue == option ? BryqoTheme.forest : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(12)
                    .background(selection.wrappedValue == option ? BryqoTheme.leaf.opacity(0.18) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.cornerRadius, style: .continuous))
                }
            }
        }
        .bryqoCard()
    }
}

#Preview {
    OnboardingView(appState: BryqoAppState())
}
