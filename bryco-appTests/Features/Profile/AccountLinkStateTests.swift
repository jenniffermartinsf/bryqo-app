import AuthenticationServices
import Foundation
import Testing
@testable import bryco_app

/// Covers how a failed "Salvar com Apple" attempt maps to what the Profile card shows.
@Suite("Account link state")
struct AccountLinkStateTests {

    @Test("Closing the Apple sheet returns to idle without an error")
    func cancellationIsNotAnError() {
        let state = AccountLinkState.afterFailure(ASAuthorizationError(.canceled))

        #expect(state == .idle)
        #expect(state.errorMessage == nil)
    }

    @Test("Any other failure surfaces its message")
    func realFailureShowsMessage() {
        let state = AccountLinkState.afterFailure(BryqoAuthError.invalidCredential)

        #expect(state == .failed(message: "Credencial Apple inválida."))
        #expect(state.errorMessage == "Credencial Apple inválida.")
    }

    @Test("Only the failed state carries an error message", arguments: [
        AccountLinkState.idle, .linking, .linked
    ])
    func nonFailedStatesHaveNoMessage(state: AccountLinkState) {
        #expect(state.errorMessage == nil)
    }
}
