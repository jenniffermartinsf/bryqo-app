import SwiftUI
import PhotosUI

struct ProfileView: View {
    let appState: BryqoAppState

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isSigningIn = false
    @State private var signInErrorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Perfil")
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                avatarSection
                statsSection
                settingsSection
                supportSection
            }
            .padding(BryqoTheme.Spacing.xl)
        }
        .background(BryqoTheme.background)
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    appState.avatarImageData = data
                }
            }
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: BryqoTheme.Spacing.lg) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                avatarCircle
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(BryqoTheme.primary)
                            .clipShape(Circle())
                            .overlay { Circle().stroke(BryqoTheme.background, lineWidth: 2) }
                            .offset(x: 2, y: 2)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Alterar foto de perfil")

            VStack(spacing: BryqoTheme.Spacing.sm) {
                Text(appState.profile?.displayName ?? "construtor")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(BryqoTheme.textPrimary)

                Text("Construindo desde \(creationMonth) · Nível \(appState.levelName)")
                    .font(.body)
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .bryqoCard()
    }

    @ViewBuilder
    private var avatarCircle: some View {
        if let data = appState.avatarImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
        } else {
            Image("BrixNeutro")
                .resizable()
                .scaledToFit()
                .padding(10)
                .frame(width: 96, height: 96)
                .background(
                    LinearGradient(
                        colors: [BryqoTheme.river.opacity(0.25), BryqoTheme.primary.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(BryqoTheme.border, lineWidth: 1.5)
                }
        }
    }

    private var creationMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: appState.profile?.accountCreatedDate ?? Date())
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            statCard(
                value: "\(appState.progress.streakDays)",
                label: "dias",
                icon: "flame.fill",
                color: BryqoTheme.coral
            )
            statCard(
                value: "\(appState.progress.xp)",
                label: "XP",
                icon: "star.fill",
                color: BryqoTheme.sun
            )
            statCard(
                value: "\(appState.completedLessonCount)",
                label: "lições",
                icon: "checkmark.circle.fill",
                color: BryqoTheme.primary
            )
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: BryqoTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(BryqoTheme.textPrimary)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BryqoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BryqoTheme.Radius.card, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1.5)
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Aparência")

            settingToggle(
                title: "Tema escuro",
                subtitle: appState.isLightMode
                    ? "Ativa a interface escura."
                    : "Interface usando o tema escuro.",
                isOn: Binding(
                    get: { !appState.isLightMode },
                    set: { appState.isLightMode = !$0 }
                )
            )

            BryqoSectionTitle(title: "Notificações")
                .padding(.top, BryqoTheme.Spacing.md)

            settingToggle(
                title: "Lembrete diário",
                subtitle: "Brix te avisa às 19h se você ainda não estudou.",
                isOn: Binding(
                    get: { appState.notificationsEnabled },
                    set: { appState.setNotificationsEnabled($0) }
                )
            )

            BryqoSectionTitle(title: "Conta")
                .padding(.top, BryqoTheme.Spacing.md)

            accountAuthCard

            Button {
                appState.resetOnboarding()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                        Text("Rever onboarding")
                            .font(.headline.bold())
                            .foregroundStyle(BryqoTheme.textPrimary)
                        Text("Reconfigure seus objetivos e perfil.")
                            .font(.body)
                            .foregroundStyle(BryqoTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                .bryqoCard()
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var accountAuthCard: some View {
        let auth = appState.authManager
        if auth.isAnonymous || !auth.isSignedIn {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                HStack(spacing: BryqoTheme.Spacing.md) {
                    Image(systemName: "exclamationmark.icloud.fill")
                        .font(.title2)
                        .foregroundStyle(BryqoTheme.warning)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Progresso sem backup")
                            .font(.headline.bold())
                            .foregroundStyle(BryqoTheme.textPrimary)
                        Text("Reinstalar o app apaga tudo. Vincule sua Apple ID para salvar.")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BryqoTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button {
                    isSigningIn = true
                    Task {
                        do {
                            try await auth.signInWithApple()
                        } catch {
                            let nsErr = error as NSError
                            // ASAuthorizationError.canceled (1001) is user dismissal — not an error to show
                            if nsErr.domain != "com.apple.AuthenticationServices.AuthorizationError" || nsErr.code != 1001 {
                                signInErrorMessage = error.localizedDescription
                            }
                        }
                        isSigningIn = false
                    }
                } label: {
                    HStack(spacing: BryqoTheme.Spacing.sm) {
                        if isSigningIn {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "apple.logo")
                        }
                        Text(isSigningIn ? "Vinculando…" : "Salvar com Apple")
                            .font(.headline.bold())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.black)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isSigningIn)
            }
            .bryqoCard()
            .alert("Erro ao vincular conta", isPresented: .init(
                get: { signInErrorMessage != nil },
                set: { if !$0 { signInErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(signInErrorMessage ?? "")
            }
        } else {
            HStack(spacing: BryqoTheme.Spacing.md) {
                Image(systemName: "checkmark.icloud.fill")
                    .font(.title2)
                    .foregroundStyle(BryqoTheme.success)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Conta vinculada")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("Progresso salvo com sua Apple ID.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                Spacer()
            }
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
                .tint(BryqoTheme.primary)
        }
        .bryqoCard()
    }

    // MARK: - Support

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            BryqoSectionTitle(title: "Suporte")

            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
                Label("Login anônimo + Sign in with Apple", systemImage: "person.badge.shield.checkmark.fill")
                Label("Sincronização com Firestore em breve", systemImage: "icloud")
                Label("Dados não são compartilhados com terceiros", systemImage: "lock.fill")
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(BryqoTheme.textSecondary)
            .bryqoCard()
        }
    }
}
