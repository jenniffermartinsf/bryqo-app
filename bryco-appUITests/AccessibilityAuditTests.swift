import XCTest

/// Runs Apple's accessibility audit (contrast, Dynamic Type, element descriptions, hit regions,
/// clipped text…) on every tab and on a lesson, in both themes, at the default text size and at
/// the largest accessibility size.
final class AccessibilityAuditTests: XCTestCase {
    private static let tabs = ["Vale", "Aprender", "Mochila", "Conquistas", "Perfil"]

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testLightThemeAtDefaultTextSize() throws {
        try audit(lightMode: true, contentSize: nil)
    }

    @MainActor
    func testLightThemeAtLargestAccessibilityTextSize() throws {
        try audit(lightMode: true, contentSize: Self.largestTextSize)
    }

    @MainActor
    func testDarkThemeAtDefaultTextSize() throws {
        try audit(lightMode: false, contentSize: nil)
    }

    @MainActor
    func testDarkThemeAtLargestAccessibilityTextSize() throws {
        try audit(lightMode: false, contentSize: Self.largestTextSize)
    }

    /// Status bar plus Dynamic Island on the iPhone 17 the suite runs on.
    private static let statusBarHeight: CGFloat = 62

    private static let largestTextSize = "UICTContentSizeCategoryAccessibilityXXXL"

    @MainActor
    private func audit(lightMode: Bool, contentSize: String?) throws {
        let app = XCUIApplication()
        // Perfil › Aparência; the argument domain overrides whatever the simulator has stored.
        app.launchArguments = ["-BryqoSkipOnboarding", "-bryqo.appearance", lightMode ? "light" : "dark"]
        if let contentSize {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", contentSize]
        }
        app.launch()

        // At the largest size two checks add nothing, and on the long learning path they run past
        // the audit's time limit: Dynamic Type (it steps through the sizes; we're at the top) and
        // contrast (bigger text never needs more of it: WCAG asks 4.5:1 for body text, 3:1 for
        // large). Both run at the default size, in both themes.
        let types: XCUIAccessibilityAuditType = contentSize == nil
            ? .all
            : .all.subtracting([.dynamicType, .contrast])

        for tab in Self.tabs {
            app.tabBars.buttons[tab].tap()
            auditScreen(app, named: tab, types: types)
        }

        app.tabBars.buttons["Aprender"].tap()
        let firstLesson = app.buttons["Instruções Precisas"].firstMatch
        if firstLesson.waitForExistence(timeout: 3) {
            firstLesson.tap()
            // Wait for the push to finish: mid-transition the audit reads half-drawn views.
            _ = app.otherElements["Progresso da lição"].waitForExistence(timeout: 3)
            auditScreen(app, named: "Lição", types: types)
        }
    }

    @MainActor
    private func auditScreen(_ app: XCUIApplication, named screen: String, types: XCUIAccessibilityAuditType) {
        // One audit type per call: a long screen at the largest text size can't fit them all in the
        // audit's time limit. A call that still can't finish fails this screen only.
        let each: [XCUIAccessibilityAuditType] = [
            .contrast, .elementDetection, .hitRegion, .sufficientElementDescription,
            .dynamicType, .textClipped, .trait,
        ]
        for type in each where types.contains(type) {
            do {
                try audit(app, named: screen, types: type)
            } catch {
                XCTFail("[\(screen)] \(type) audit didn't run: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func audit(_ app: XCUIApplication, named screen: String, types: XCUIAccessibilityAuditType) throws {
        try app.performAccessibilityAudit(for: types) { issue in
            // Progress bars and the hearts row are 8–12 pt indicators VoiceOver reads ("Progresso
            // da lição, 40%"); nothing taps them, so the hit-region rule doesn't apply. Buttons
            // and every other tappable element are still checked.
            if issue.auditType == .hitRegion, issue.element?.elementType == .other {
                return true
            }
            // Text scrolled under the status bar, under the translucent tab bar (or its shadow), or
            // off the bottom of the screen is measured through whatever covers it. The person scrolls
            // it into view to read it.
            let tabBar = app.tabBars.firstMatch
            let visibleTop = app.windows.firstMatch.frame.minY + Self.statusBarHeight
            let visibleBottom = tabBar.exists ? tabBar.frame.minY - 24 : app.windows.firstMatch.frame.maxY
            if issue.auditType == .contrast, let element = issue.element,
               element.frame.minY < visibleTop || element.frame.maxY > visibleBottom {
                return true
            }
            let element = issue.element.map { "\($0.elementType.rawValue) “\($0.label)”" } ?? "–"
            XCTFail("[\(screen)] \(issue.auditType) · \(element) · \(issue.compactDescription)")
            return true
        }
    }
}
