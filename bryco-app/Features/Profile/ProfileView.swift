import SwiftUI

struct ProfileView: View {
    let appState: BryqoAppState

    @State private var notificationsEnabled = false
    @State private var reduceMotion = false

    private let goalOptions = [5, 10, 15, 20]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Perfil")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                accountCard
                dailyGoalCard
                settingsSection
                supportSection
            }
            .padding(BryqoTheme.Spacing.xl)
        }
    }

    private var accountCard: some View {
        HStack(spacing: BryqoTheme.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(BryqoTheme.wood.opacity(0.18))
                    .frame(width: 76, height: 76)
                Image(systemName: "person")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xD6A36E))
            }

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.md) {
                Text(appState.profile?.displayName ?? "construtor")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Text("Conta local")
                    .font(.headline.bold())
                    .foregroundStyle(Color(hex: 0xD6A36E))
                    .padding(.horizontal, BryqoTheme.Spacing.lg)
                    .padding(.vertical, BryqoTheme.Spacing.sm)
                    .background(BryqoTheme.wood.opacity(0.18))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .bryqoCard()
    }

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Meta diária")

            HStack(spacing: BryqoTheme.Spacing.md) {
                ForEach(goalOptions, id: \.self) { minutes in
                    Text("\(minutes) min")
                        .font(.headline.bold())
                        .foregroundStyle((appState.profile?.dailyGoalMinutes ?? 10) == minutes ? BryqoTheme.river : BryqoTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background((appState.profile?.dailyGoalMinutes ?? 10) == minutes ? BryqoTheme.river.opacity(0.16) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: BryqoTheme.Radius.input, style: .continuous)
                                .stroke((appState.profile?.dailyGoalMinutes ?? 10) == minutes ? BryqoTheme.river : BryqoTheme.border, lineWidth: 1.5)
                        }
                }
            }
        }
        .bryqoCard()
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Notificações")
            settingToggle(
                title: "Lembrete diário",
                subtitle: "Brix te avisa às 19h se você ainda não estudou.",
                isOn: $notificationsEnabled
            )

            BryqoSectionTitle(title: "Acessibilidade")
                .padding(.top, BryqoTheme.Spacing.md)
            settingToggle(
                title: "Reduzir movimento",
                subtitle: "Desativa vibrações e efeitos de destaque nos exercícios.",
                isOn: $reduceMotion
            )

            settingToggle(
                title: "Modo claro",
                subtitle: appState.isLightMode ? "A interface está usando o tema claro." : "A interface está usando o tema escuro.",
                isOn: Binding(
                    get: { appState.isLightMode },
                    set: { appState.isLightMode = $0 }
                )
            )
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Suporte")

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                Label("Progresso salvo neste dispositivo", systemImage: "iphone")
                Label("Login e sincronização ficam para o MVP", systemImage: "icloud.slash")
                Label("Dados locais não são compartilhados com terceiros", systemImage: "lock.fill")
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(BryqoTheme.textSecondary)
            .bryqoCard()
        }
    }

    private func settingToggle(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: BryqoTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundStyle(BryqoTheme.textPrimary)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(BryqoTheme.textSecondary)
                    .lineSpacing(3)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(BryqoTheme.river)
        }
        .bryqoCard()
    }
}
