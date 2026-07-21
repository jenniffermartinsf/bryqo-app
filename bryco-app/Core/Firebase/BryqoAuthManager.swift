import FirebaseAuth
import AuthenticationServices
import CryptoKit

@Observable
final class BryqoAuthManager: NSObject, @unchecked Sendable {
    var currentUID: String? = nil
    var isAnonymous: Bool = true
    var isSignedIn: Bool = false

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
                if let user = Auth.auth().currentUser, user.isAnonymous {
                    _ = try await user.link(with: firebaseCred)
                } else {
                    _ = try await Auth.auth().signIn(with: firebaseCred)
                }
                pendingContinuation?.resume()
            } catch let err as NSError where err.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                // Apple ID already linked to another Firebase account — sign in to that account
                let fallback = (err.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential) ?? firebaseCred
                do {
                    _ = try await Auth.auth().signIn(with: fallback)
                    pendingContinuation?.resume()
                } catch {
                    pendingContinuation?.resume(throwing: error)
                }
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
    var errorDescription: String? { "Credencial Apple inválida." }
}
