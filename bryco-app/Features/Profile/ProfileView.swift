import SwiftUI
import PhotosUI

struct ProfileView: View {
    let appState: BryqoAppState

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPickingPhoto = false
    @State private var linkState: AccountLinkState = .idle
    @State private var isConfirmingReviewReset = false
    /// Which provider the current link attempt uses, so only its button shows progress.
    @State private var linkingProvider: AccountProvider?

    private enum AccountProvider { case apple, google }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BryqoTheme.Spacing.xl) {
                Text("Perfil")
                    .bryqoFont(34, relativeTo: .largeTitle, weight: .black)
                    .foregroundStyle(BryqoTheme.textPrimary)

                avatarSection
                statsSection
                settingsSection
                supportSection
            }
            .padding(BryqoTheme.Spacing.xl)
        }
        .background(BryqoTheme.background)
        .task { await appState.loadAvatar() }
        // Tied to the selection: picking another photo cancels the one still loading.
        .task(id: selectedPhotoItem) {
            guard let item = selectedPhotoItem,
                  let photo = try? await item.loadTransferable(type: Data.self) else { return }
            try? await appState.setAvatar(photo)
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: BryqoTheme.Spacing.lg) {
            // A Button + .photosPicker keeps the label on the main actor; PhotosPicker's own
            // label closure must be Sendable, which a view built from main-actor state isn't.
            Button { isPickingPhoto = true } label: {
                avatarCircle
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .bryqoFont(13, weight: .bold)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(BryqoTheme.primary)
                            .clipShape(Circle())
                            .overlay { Circle().stroke(BryqoTheme.background, lineWidth: 2) }
                            .offset(x: 2, y: 2)
                    }
            }
            .buttonStyle(.plain)
            .photosPicker(isPresented: $isPickingPhoto, selection: $selectedPhotoItem, matching: .images)
            .accessibilityLabel("Alterar foto de perfil")

            VStack(spacing: BryqoTheme.Spacing.sm) {
                Text(appState.profile?.displayName ?? "construtor")
                    .bryqoFont(26, relativeTo: .title2, weight: .black)
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
        if let uiImage = appState.avatarImage {
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
                .bryqoFont(26, relativeTo: .title2, weight: .black)
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
                isConfirmingReviewReset = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: BryqoTheme.Spacing.sm) {
                        Text("Recomeçar revisões")
                            .font(.headline.bold())
                            .foregroundStyle(BryqoTheme.textPrimary)
                        Text("Limpa a agenda de revisão espaçada. Lições e XP continuam.")
                            .font(.body)
                            .foregroundStyle(BryqoTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                }
                .bryqoCard()
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Recomeçar as revisões?",
                isPresented: $isConfirmingReviewReset,
                titleVisibility: .visible
            ) {
                Button("Recomeçar revisões", role: .destructive) {
                    appState.resetReviews()
                }
            } message: {
                Text("A agenda de revisões será apagada. Suas lições concluídas e seu XP não mudam.")
            }

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

    /// The card's displayed state. `.linked` comes straight from the auth manager (the source
    /// of truth for the account); every other case reflects the current link attempt.
    private var accountState: AccountLinkState {
        let auth = appState.authManager
        return auth.isSignedIn && !auth.isAnonymous ? .linked : linkState
    }

    @ViewBuilder
    private var accountAuthCard: some View {
        switch accountState {
        case .linked:
            linkedAccountCard
        case .idle, .failed:
            unlinkedAccountCard(isLinking: false)
        case .linking:
            unlinkedAccountCard(isLinking: true)
        }
    }

    private func unlinkedAccountCard(isLinking: Bool) -> some View {
        VStack(alignment: .leading, spacing: BryqoTheme.Spacing.lg) {
            HStack(spacing: BryqoTheme.Spacing.md) {
                Image(systemName: "exclamationmark.icloud.fill")
                    .font(.title2)
                    .foregroundStyle(BryqoTheme.warning)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Progresso sem backup")
                        .font(.headline.bold())
                        .foregroundStyle(BryqoTheme.textPrimary)
                    Text("Reinstalar o app apaga tudo. Vincule uma conta para salvar.")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BryqoTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            BryqoAuthButton(
                provider: .apple,
                isLoading: isLinking && linkingProvider == .apple,
                isDisabled: isLinking,
                action: linkWithApple
            )

            if appState.authManager.isGoogleSignInAvailable {
                BryqoAuthButton(
                    provider: .google,
                    isLoading: isLinking && linkingProvider == .google,
                    isDisabled: isLinking,
                    action: linkWithGoogle
                )
            }
        }
        .bryqoCard()
        .alert("Erro ao vincular conta", isPresented: .init(
            get: { linkState.errorMessage != nil },
            set: { if !$0 { linkState = .idle } }
        )) {
        } message: {
            Text(linkState.errorMessage ?? "")
        }
    }

    private var linkedAccountCard: some View {
        HStack(spacing: BryqoTheme.Spacing.md) {
            Image(systemName: "checkmark.icloud.fill")
                .font(.title2)
                .foregroundStyle(BryqoTheme.success)
            VStack(alignment: .leading, spacing: 3) {
                Text("Conta vinculada")
                    .font(.headline.bold())
                    .foregroundStyle(BryqoTheme.textPrimary)
                Text("Progresso salvo com sua conta \(appState.authManager.linkedProviderName ?? "vinculada").")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BryqoTheme.textSecondary)
            }
            Spacer()
        }
        .bryqoCard()
    }

    private func linkWithApple() {
        link(.apple) { try await appState.authManager.signInWithApple() }
    }

    private func linkWithGoogle() {
        link(.google) { try await appState.authManager.signInWithGoogle() }
    }

    private func link(_ provider: AccountProvider, signIn: @escaping () async throws -> Void) {
        linkingProvider = provider
        linkState = .linking
        Task {
            do {
                try await signIn()
                linkState = .idle
                // The account may have switched to an existing user: reconcile with its backup.
                await appState.syncWithCloud()
            } catch {
                linkState = .afterFailure(error)
            }
            linkingProvider = nil
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
                Label("Login anônimo, Apple ou Google", systemImage: "person.badge.shield.checkmark.fill")
                Label("Backup na nuvem quando há internet", systemImage: "icloud")
                Label("Dados não são compartilhados com terceiros", systemImage: "lock.fill")
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(BryqoTheme.textSecondary)
            .bryqoCard()
        }
    }
}
