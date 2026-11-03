import XCTest

/// Layout checks the accessibility audit can't make: it reports clipped text, not a progress
/// bar squeezed to a dot. Runs the lesson screen at sizes across the whole Dynamic Type range.
final class DynamicTypeLayoutTests: XCTestCase {
    private static let sizes = [
        "UICTContentSizeCategoryXS", "UICTContentSizeCategoryL", "UICTContentSizeCategoryXXXL",
        "UICTContentSizeCategoryAccessibilityM", "UICTContentSizeCategoryAccessibilityXXXL",
    ]

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    func testLessonProgressBarKeepsItsWidthAtEveryTextSize() throws {
        for size in Self.sizes {
            let app = XCUIApplication()
            app.launchArguments = ["-BryqoSkipOnboarding", "-UIPreferredContentSizeCategoryName", size]
            app.launch()
            app.tabBars.buttons["Aprender"].tap()
            app.buttons["Instruções Precisas"].firstMatch.tap()

            let bar = app.otherElements["Progresso da lição"]
            XCTAssertTrue(bar.waitForExistence(timeout: 5), size)
            let screen = app.windows.firstMatch.frame.width
            // At least a third of the screen: wide enough to read how far the lesson has gone.
            XCTAssertGreaterThanOrEqual(bar.frame.width, screen / 3, "\(size): bar is \(Int(bar.frame.width)) pt")

            let hearts = app.otherElements["Vidas"]
            XCTAssertLessThanOrEqual(hearts.frame.maxX, screen, "\(size): hearts run off the screen")
            app.terminate()
        }
    }
}
