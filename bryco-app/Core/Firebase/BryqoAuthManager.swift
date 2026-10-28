import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

/// Signed-in state and account linking. Main-actor isolated: Firebase Auth, AuthenticationServices
/// and Google Sign-In all call back on the main thread, and the UI reads this state directly.
@MainActor
@Observable
final class BryqoAuthManager: NSObject {
    var currentUID: String? = nil
    var isAnonymous: Bool = true
    var isSignedIn: Bool = false
    /// The provider the account is linked to ("Apple" or "Google"), or nil while anonymous.
    var linkedProviderName: String? = nil

    @ObservationIgnored private var authStateHandle: AuthStateDidChangeListenerHandle?
    /// The Apple sign-in in flight: the raw nonce, the bridge waiting for the delegate and the
    /// controller (kept so cancelling the task can dismiss the sheet).
    @ObservationIgnored private var appleSignIn: (
        nonce: String,
        callback: OneShotContinuation<ASAuthorization>,
        controller: ASAuthorizationController
    )?

    override init() {
        super.init()
        // Firebase delivers auth state changes on the main thread.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            MainActor.assumeIsolated {
                self?.apply(user)
            }
        }
    }

    isolated deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    private func apply(_ user: User?) {
        currentUID = user?.uid
        isAnonymous = user?.isAnonymous ?? true
        isSignedIn = user != nil
        linkedProviderName = Self.providerName(for: user)
        if let uid = user?.uid {
            BryqoAnalytics.identifyUser(uid)
        }
    }

    // Signs in anonymously on first launch. Silent no-op if already signed in.
    func signInAnonymouslyIfNeeded() async {
        if let user = Auth.auth().currentUser {
            apply(user)
            return
        }
        do {
            let result = try await Auth.auth().signInAnonymously()
            apply(result.user)
        } catch {
            // Silent fail — local SwiftData progress still works without auth
        }
    }

    /// Presents the Apple sheet and links the credential to the anonymous account. Reads top
    /// to bottom: the delegate only forwards its result into `OneShotContinuation`.
    /// Throws on failure (caller shows an alert); cancelling the task dismisses the sheet.
    func signInWithApple() async throws {
        guard appleSignIn == nil else { throw BryqoAuthError.signInInProgress }

        let nonce = randomNonce()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        defer { appleSignIn = nil }
        let authorization = try await OneShotContinuation<ASAuthorization>.run { callback in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            appleSignIn = (nonce, callback, controller)
            controller.performRequests()
        } onCancel: { [weak self] in
            self?.appleSignIn?.controller.cancel()
        }

        guard
            let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            throw BryqoAuthError.invalidCredential
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        try await linkOrSignIn(with: credential)
    }

    /// Whether this build has a Google OAuth client configured (the CI placeholder config doesn't).
    var isGoogleSignInAvailable: Bool {
        FirebaseApp.app()?.options.clientID != nil
    }

    // Presents Google Sign-In and links the account to the anonymous user, exactly like Apple:
    // progress stays on the same Firebase user. Throws on failure (caller shows an alert).
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw BryqoAuthError.googleNotConfigured
        }
        guard let presenter = Self.topViewController() else {
            throw BryqoAuthError.noPresenter
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        guard let idToken = result.user.idToken?.tokenString else {
            throw BryqoAuthError.invalidCredential
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        try await linkOrSignIn(with: credential)
    }

    /// Links `credential` to the anonymous account so progress stays on the same user. If the
    /// provider account already belongs to another Firebase user, signs in to that user instead.
    private func linkOrSignIn(with credential: AuthCredential) async throws {
        do {
            if let user = Auth.auth().currentUser, user.isAnonymous {
                _ = try await user.link(with: credential)
            } else {
                _ = try await Auth.auth().signIn(with: credential)
            }
        } catch let error as NSError where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
            let existing = (error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential) ?? credential
            _ = try await Auth.auth().signIn(with: existing)
        }
        apply(Auth.auth().currentUser)
    }

    private static func providerName(for user: User?) -> String? {
        let ids = Set(user?.providerData.map(\.providerID) ?? [])
        if ids.contains("google.com") { return "Google" }
        if ids.contains("apple.com") { return "Apple" }
        return nil
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var top = scene?.keyWindow?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }

    // MARK: - Helpers

    private func randomNonce(length: Int = 32) -> String {
        var bytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(bytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

// The delegate no longer holds any logic: it forwards the result to whoever is awaiting it.
extension BryqoAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        appleSignIn?.callback.resume(with: .success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        appleSignIn?.callback.resume(with: .failure(error))
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension BryqoAuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let allScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        // A running app always has at least one scene — the force-unwrap is safe here
        let scene = allScenes.first(where: { $0.activationState == .foregroundActive }) ?? allScenes.first!
        return scene.keyWindow ?? UIWindow(windowScene: scene)
    }
}

enum BryqoAuthError: LocalizedError {
    case invalidCredential
    case googleNotConfigured
    case noPresenter
    case signInInProgress

    var errorDescription: String? {
        switch self {
        case .invalidCredential: "Credencial inválida."
        case .googleNotConfigured: "O login com Google não está configurado neste app."
        case .noPresenter: "Não foi possível abrir a tela de login."
        case .signInInProgress: "Já existe um login em andamento."
        }
    }
}

extension BryqoAuthManager: AccountLinking {
    var isLinked: Bool { isSignedIn && !isAnonymous }

    func signIn(with provider: AccountProvider) async throws {
        switch provider {
        case .apple: try await signInWithApple()
        case .google: try await signInWithGoogle()
        }
    }
}
