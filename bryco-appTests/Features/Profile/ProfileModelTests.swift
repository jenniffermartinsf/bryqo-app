import AuthenticationServices
import Foundation
import Testing
@testable import bryco_app

/// Stands in for Firebase: records sign-ins and fails or succeeds on demand.
final class FakeAccount: AccountLinking {
    var isLinked = false
    var linkedProviderName: String?
    var isGoogleSignInAvailable = true
    var failure: Error?
    private(set) var signIns: [AccountProvider] = []

    func signIn(with provider: AccountProvider) async throws {
        signIns.append(provider)
        if let failure { throw failure }
        isLinked = true
        linkedProviderName = provider == .apple ? "Apple" : "Google"
    }
}

@MainActor
@Suite("Profile model")
struct ProfileModelTests {
    let appState = BryqoAppState(inMemory: true)
    let account = FakeAccount()

    private func makeModel(onSync: @escaping () -> Void = {}) -> ProfileModel {
        ProfileModel(appState: appState, account: account, syncWithCloud: { onSync() })
    }

    @Test("Linking succeeds, shows the account as linked and backs up the progress")
    func linkSucceeds() async {
        var syncs = 0
        let model = makeModel { syncs += 1 }

        await model.link(with: .google)

        #expect(account.signIns == [.google])
        #expect(model.accountState == .linked)
        #expect(model.linkedProviderName == "Google")
        #expect(syncs == 1)
    }

    @Test("A failed link shows the error and skips the backup")
    func linkFails() async {
        var syncs = 0
        account.failure = BryqoAuthError.invalidCredential
        let model = makeModel { syncs += 1 }

        await model.link(with: .apple)

        #expect(model.accountState == .failed(message: "Credencial inválida."))
        #expect(syncs == 0)

        model.dismissError()
        #expect(model.accountState == .idle)
    }

    @Test("Closing the sign-in sheet goes back to idle, with no error")
    func linkCanceled() async {
        account.failure = ASAuthorizationError(.canceled)
        let model = makeModel()

        await model.link(with: .apple)

        #expect(model.accountState == .idle)
    }

    @Test("While linking, only the chosen provider shows progress")
    func linkingShowsProvider() async {
        let (signInStarted, started) = AsyncStream<Void>.makeStream()
        let (signInMayFinish, release) = AsyncStream<Void>.makeStream()
        let account = GatedAccount(started: started, mayFinish: signInMayFinish)
        let model = ProfileModel(appState: appState, account: account, syncWithCloud: {})

        let linking = Task { await model.link(with: .google) }
        for await _ in signInStarted { break }

        #expect(model.accountState.isLinking(with: .google))
        #expect(!model.accountState.isLinking(with: .apple))

        // A second tap while linking is ignored.
        await model.link(with: .apple)
        #expect(account.signIns == [.google])

        release.yield()
        await linking.value
        #expect(model.accountState == .idle)
    }

    @Test("The subtitle shows the month the account was created and the level")
    func subtitle() throws {
        let march = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 10)))
        appState.profile = OnboardingProfile(
            displayName: "Ana", experience: "", goal: "", dailyGoalMinutes: 10, accountCreatedDate: march
        )
        let model = makeModel()

        #expect(model.displayName == "Ana")
        #expect(model.subtitle == "Construindo desde março · Nível \(appState.levelName)")
    }

    @Test("The dark theme switch flips the app's light mode")
    func darkModeSwitch() {
        let model = makeModel()
        let original = appState.isLightMode
        defer { appState.isLightMode = original }

        model.isDarkMode = true
        #expect(!appState.isLightMode)
        #expect(model.themeSubtitle == "Interface usando o tema escuro.")

        model.isDarkMode = false
        #expect(appState.isLightMode)
    }

    @Test("Without a profile, the name falls back to \"construtor\"")
    func nameFallback() {
        appState.profile = nil

        #expect(makeModel().displayName == "construtor")
    }
}

/// A sign-in that waits until the test lets it finish.
final class GatedAccount: AccountLinking {
    let isLinked = false
    let linkedProviderName: String? = nil
    let isGoogleSignInAvailable = true
    private(set) var signIns: [AccountProvider] = []
    private let started: AsyncStream<Void>.Continuation
    private let mayFinish: AsyncStream<Void>

    init(started: AsyncStream<Void>.Continuation, mayFinish: AsyncStream<Void>) {
        self.started = started
        self.mayFinish = mayFinish
    }

    func signIn(with provider: AccountProvider) async throws {
        signIns.append(provider)
        started.yield()
        for await _ in mayFinish { break }
    }
}
