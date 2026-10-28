import AuthenticationServices
import Foundation
import GoogleSignIn
import Testing
@testable import bryco_app

/// Covers how a failed "Salvar com Apple" attempt maps to what the Profile card shows.
@MainActor
@Suite("Account link state")
struct AccountLinkStateTests {

    @Test("Closing the Apple sheet returns to idle without an error")
    func cancellationIsNotAnError() {
        let state = AccountLinkState.afterFailure(ASAuthorizationError(.canceled))

        #expect(state == .idle)
        #expect(state.errorMessage == nil)
    }

    @Test("Closing the Google sheet returns to idle without an error")
    func googleCancellationIsNotAnError() {
        let canceled = NSError(domain: kGIDSignInErrorDomain, code: GIDSignInError.Code.canceled.rawValue)

        #expect(AccountLinkState.afterFailure(canceled) == .idle)
    }

    @Test("Any other failure surfaces its message")
    func realFailureShowsMessage() {
        let state = AccountLinkState.afterFailure(BryqoAuthError.invalidCredential)

        #expect(state == .failed(message: "Credencial inválida."))
        #expect(state.errorMessage == "Credencial inválida.")
    }

    @Test("Only the failed state carries an error message", arguments: [
        AccountLinkState.idle, .linking(.apple), .linked
    ])
    func nonFailedStatesHaveNoMessage(state: AccountLinkState) {
        #expect(state.errorMessage == nil)
    }
}
