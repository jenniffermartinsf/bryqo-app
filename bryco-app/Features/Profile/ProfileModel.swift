import Foundation
import Observation
import PhotosUI
import SwiftUI

/// What the Profile screen needs from the account: Firebase in the app, a fake in tests.
protocol AccountLinking: AnyObject {
    /// Signed in with Apple or Google (not just the anonymous account).
    var isLinked: Bool { get }
    var linkedProviderName: String? { get }
    var isGoogleSignInAvailable: Bool { get }
    func signIn(with provider: AccountProvider) async throws
}

/// The Profile screen's data and behaviour. `ProfileView` only draws it and forwards taps.
@Observable
final class ProfileModel {
    private let appState: BryqoAppState
    @ObservationIgnored private let account: AccountLinking
    @ObservationIgnored private let syncWithCloud: () async -> Void

    /// The current link attempt. Whether the account *is* linked comes from `account`.
    private(set) var linkAttempt: AccountLinkState = .idle

    init(
        appState: BryqoAppState,
        account: AccountLinking? = nil,
        syncWithCloud: (() async -> Void)? = nil
    ) {
        self.appState = appState
        self.account = account ?? appState.authManager
        self.syncWithCloud = syncWithCloud ?? { await appState.syncWithCloud() }
    }

    // MARK: - Header and stats

    var displayName: String { appState.profile?.displayName ?? "construtor" }

    var subtitle: String {
        let created = appState.profile?.accountCreatedDate ?? .now
        let month = created.formatted(.dateTime.month(.wide).locale(Locale(identifier: "pt_BR")))
        return "Construindo desde \(month) · Nível \(appState.levelName)"
    }

    var streakDays: Int { appState.progress.streakDays }
    var xp: Int { appState.progress.xp }
    var completedLessons: Int { appState.completedLessonCount }
    var avatarImage: UIImage? { appState.avatarImage }

    // MARK: - Avatar

    func loadAvatar() async {
        await appState.loadAvatar()
    }

    func usePhoto(_ item: PhotosPickerItem?) async {
        guard let item, let photo = try? await item.loadTransferable(type: Data.self) else { return }
        try? await appState.setAvatar(photo)
    }

    // MARK: - Settings

    var isDarkMode: Bool {
        get { !appState.isLightMode }
        set { appState.isLightMode = !newValue }
    }

    var themeSubtitle: String {
        isDarkMode ? "Interface usando o tema escuro." : "Ativa a interface escura."
    }

    var remindersEnabled: Bool {
        get { appState.notificationsEnabled }
        set { appState.setNotificationsEnabled(newValue) }
    }

    func resetReviews() {
        appState.resetReviews()
    }

    /// Clearing the profile sends the app back to onboarding (`ContentView` switches on it).
    func restartOnboarding() {
        appState.resetOnboarding()
    }

    // MARK: - Account

    /// `.linked` comes straight from the account (the source of truth); every other case
    /// reflects the current link attempt.
    var accountState: AccountLinkState {
        account.isLinked ? .linked : linkAttempt
    }

    var linkedProviderName: String { account.linkedProviderName ?? "vinculada" }
    var isGoogleSignInAvailable: Bool { account.isGoogleSignInAvailable }

    func link(with provider: AccountProvider) async {
        guard !linkAttempt.isLinking else { return }
        linkAttempt = .linking(provider)
        do {
            try await account.signIn(with: provider)
        } catch {
            linkAttempt = .afterFailure(error)
            return
        }
        linkAttempt = .idle
        // The account may have switched to an existing user: reconcile with its backup.
        await syncWithCloud()
    }

    func dismissError() {
        linkAttempt = .idle
    }
}
