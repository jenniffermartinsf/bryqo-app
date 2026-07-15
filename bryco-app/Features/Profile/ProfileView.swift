import SwiftUI

struct ProfileView: View {
    let appState: BryqoAppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BryqoTheme.spacing) {
                    profileSummary
                    prototypeStatus
                }
                .padding()
            }
            .background(BryqoTheme.softBackground.ignoresSafeArea())
            .navigationTitle("Perfil")
        }
    }

    private var profileSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferências")
                .font(.headline)

            infoRow("Experiência", appState.profile?.experience ?? "Não definida")
            infoRow("Objetivo", appState.profile?.goal ?? "Não definido")
            infoRow("Meta diária", "\(appState.profile?.dailyGoalMinutes ?? 10) minutos")
        }
        .bryqoCard()
    }

    private var prototypeStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Protótipo local")
                .font(.headline)

            Label("Progresso salvo apenas nesta sessão", systemImage: "iphone")
            Label("Login e sincronização ficam para o MVP", systemImage: "icloud.slash")
            Label("Brix usa mensagens textuais nesta versão", systemImage: "message.fill")
        }
        .foregroundStyle(.secondary)
        .bryqoCard()
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.semibold)
        }
    }
}
