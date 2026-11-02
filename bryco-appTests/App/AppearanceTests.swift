import Foundation
import SwiftUI
import Testing
@testable import bryco_app

/// Which color scheme the app asks for: the system's unless the learner picked one.
@MainActor
@Suite("Appearance")
struct AppearanceTests {
    private func defaults() -> UserDefaults {
        UserDefaults(suiteName: "bryqo-appearance-\(UUID().uuidString)")!
    }

    @Test("A new install follows the system: no color scheme is forced")
    func newInstallFollowsSystem() {
        let state = BryqoAppState(inMemory: true, defaults: defaults())

        #expect(state.appearance == .system)
        #expect(state.preferredColorScheme == nil)
    }

    @Test("Each choice maps to its color scheme", arguments: [
        (AppearancePreference.system, ColorScheme?.none),
        (.light, .light),
        (.dark, .dark),
    ])
    func choiceMapsToScheme(choice: AppearancePreference, scheme: ColorScheme?) {
        let state = BryqoAppState(inMemory: true, defaults: defaults())

        state.appearance = choice

        #expect(state.preferredColorScheme == scheme)
    }

    @Test("The choice survives a relaunch")
    func choicePersists() {
        let store = defaults()
        BryqoAppState(inMemory: true, defaults: store).appearance = .dark

        #expect(BryqoAppState(inMemory: true, defaults: store).appearance == .dark)
    }

    @Test("Someone who used the old dark-mode switch keeps their theme", arguments: [
        (true, AppearancePreference.light),
        (false, .dark),
    ])
    func oldSwitchIsKept(wasLight: Bool, expected: AppearancePreference) {
        let store = defaults()
        store.set(wasLight, forKey: "bryqo.isLightMode")

        #expect(BryqoAppState(inMemory: true, defaults: store).appearance == expected)
    }
}
