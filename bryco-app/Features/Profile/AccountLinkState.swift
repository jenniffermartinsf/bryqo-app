import AuthenticationServices
import Foundation

/// Every state the "Salvar com Apple" card can be in. A single enum instead of separate
/// flags makes impossible combinations (e.g. linking *and* failed) unrepresentable.
enum AccountLinkState: Equatable {
    case idle
    case linking
    case linked
    case failed(message: String)

    /// The state to show after a sign-in attempt throws. Closing the Apple sheet surfaces as
    /// `ASAuthorizationError.canceled`: technically an error, but a deliberate user choice,
    /// so it returns to `.idle` instead of showing an alert.
    static func afterFailure(_ error: Error) -> AccountLinkState {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            return .idle
        }
        return .failed(message: error.localizedDescription)
    }

    var errorMessage: String? {
        if case .failed(let message) = self { message } else { nil }
    }
}
