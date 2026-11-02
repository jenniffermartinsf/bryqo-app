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

/// A picked photo on its way to becoming the avatar. The avatar itself (`avatarImage`) is the
/// success state; no photo yet is the empty one.
enum AvatarUpdate: Equatable {
    case idle
    case loading
    case failed(AvatarFailure)
}

enum AvatarFailure: Equatable {
    /// The library didn't hand the photo over (an iCloud photo offline, for one).
    case couldNotLoad
    /// The data isn't an image the app can read.
    case unreadable
    /// The shrunk photo couldn't be written to disk.
    case couldNotSave

    var message: String {
        switch self {
        case .couldNotLoad: "A foto não carregou. Se ela está no iCloud, confira a conexão e tente de novo."
        case .unreadable: "Não consegui ler essa imagem. Escolha outra foto."
        case .couldNotSave: "Não consegui salvar a foto. Tente de novo."
        }
    }
}

/// The Profile screen's data and behaviour. `ProfileView` only draws it and forwards taps.
@Observable
final class ProfileModel {
    private let appState: BryqoAppState
    @ObservationIgnored private let account: AccountLinking
    @ObservationIgnored private let syncWithCloud: () async -> Void

    private(set) var avatarUpdate: AvatarUpdate = .idle
    @ObservationIgnored private var latestPick = 0

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
        guard let item else { return }
        await usePhoto { try await item.loadTransferable(type: Data.self) }
    }

    /// `loadPhoto` reads the picked photo; tests pass the data straight in.
    func usePhoto(_ loadPhoto: () async throws -> Data?) async {
        latestPick += 1
        let pick = latestPick
        avatarUpdate = .loading

        // Only the newest pick may change the state: an older one that finishes late is stale.
        func finish(_ update: AvatarUpdate) {
            if pick == latestPick { avatarUpdate = update }
        }

        let photo: Data?
        do {
            photo = try await loadPhoto()
        } catch is CancellationError {
            finish(.idle)  // left the screen mid-load; a newer pick has already moved on
            return
        } catch {
            photo = nil
        }
        guard let photo else {
            finish(.failed(.couldNotLoad))
            return
        }
        do {
            try await appState.setAvatar(photo)
            finish(.idle)
        } catch is CancellationError {
            finish(.idle)
        } catch AvatarError.unreadableImage {
            finish(.failed(.unreadable))
        } catch {
            finish(.failed(.couldNotSave))
        }
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
