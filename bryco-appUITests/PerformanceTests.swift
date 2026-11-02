import XCTest

/// Memory while browsing the screens that draw the Brix mascot (Valley, Backpack, Profile).
final class PerformanceTests: XCTestCase {
    @MainActor
    func testMemoryWhileBrowsingMascotScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-BryqoSkipOnboarding"]

        let options = XCTMeasureOptions()
        options.invocationOptions = [.manuallyStart]

        measure(metrics: [XCTMemoryMetric(application: app)], options: options) {
            app.launch()
            startMeasuring()
            for tab in ["Vale", "Mochila", "Perfil", "Vale"] {
                app.tabBars.buttons[tab].tap()
                _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2)
            }
            // The app stays alive until the block ends: the metric samples it then.
        }
    }
}
