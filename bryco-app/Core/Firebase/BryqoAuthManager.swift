import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

@Observable
final class BryqoAuthManager: NSObject, @unchecked Sendable {
    var currentUID: String? = nil
    var isAnonymous: Bool = true
    var isSignedIn: Bool = false
    /// The provider the account is linked to ("Apple" or "Google"), or nil while anonymous.
    var linkedProviderName: String? = nil

    @ObservationIgnored private var authStateHandle: AuthStateDidChangeListenerHandle?
    // Accessed only from main thread via delegate callbacks
    @ObservationIgnored private nonisolated(unsafe) var pendingNonce: String?
    @ObservationIgnored private nonisolated(unsafe) var pendingContinuation: CheckedContinuation<Void, Error>?

    override init() {
        super.init()
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUID = user?.uid
                self?.isAnonymous = user?.isAnonymous ?? true
                self?.isSignedIn = user != nil
                self?.linkedProviderName = BryqoAuthManager.providerName(for: user)
                if let uid = user?.uid {
                    BryqoAnalytics.identifyUser(uid)
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Signs in anonymously on first launch. Silent no-op if already signed in.
    func signInAnonymouslyIfNeeded() async {
        if let user = Auth.auth().currentUser {
            await MainActor.run {
                currentUID = user.uid
                isAnonymous = user.isAnonymous
                isSignedIn = true
            }
            return
        }
        do {
            let result = try await Auth.auth().signInAnonymously()
            await MainActor.run {
                currentUID = result.user.uid
                isAnonymous = true
                isSignedIn = true
            }
        } catch {
            // Silent fail — local SwiftData progress still works without auth
        }
    }

    // Presents the Apple Sign-In sheet and links the credential to the anonymous account.
    // Throws on failure (caller should show an alert).
    func signInWithApple() async throws {
        let nonce = randomNonce()
        pendingNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            pendingContinuation = continuation
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    /// Whether this build has a Google OAuth client configured (the CI placeholder config doesn't).
    var isGoogleSignInAvailable: Bool {
        FirebaseApp.app()?.options.clientID != nil
    }

    // Presents Google Sign-In and links the account to the anonymous user, exactly like Apple:
    // progress stays on the same Firebase user. Throws on failure (caller shows an alert).
    @MainActor
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
        await MainActor.run {
            let user = Auth.auth().currentUser
            currentUID = user?.uid
            isAnonymous = user?.isAnonymous ?? true
            isSignedIn = user != nil
            linkedProviderName = Self.providerName(for: user)
        }
    }

    private static func providerName(for user: User?) -> String? {
        let ids = Set(user?.providerData.map(\.providerID) ?? [])
        if ids.contains("google.com") { return "Google" }
        if ids.contains("apple.com") { return "Apple" }
        return nil
    }

    @MainActor
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

extension BryqoAuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleCred = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = pendingNonce,
            let tokenData = appleCred.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            pendingContinuation?.resume(throwing: BryqoAuthError.invalidCredential)
            pendingContinuation = nil
            return
        }

        let firebaseCred = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleCred.fullName
        )

        Task {
            do {
                try await linkOrSignIn(with: firebaseCred)
                pendingContinuation?.resume()
            } catch {
                pendingContinuation?.resume(throwing: error)
            }
            pendingContinuation = nil
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        pendingContinuation?.resume(throwing: error)
        pendingContinuation = nil
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

    var errorDescription: String? {
        switch self {
        case .invalidCredential: "Credencial inválida."
        case .googleNotConfigured: "O login com Google não está configurado neste app."
        case .noPresenter: "Não foi possível abrir a tela de login."
        }
    }
}
