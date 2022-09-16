import Scenarios
import XCTest
import Scenarios

class AdviceForIndexCasesEnglandAlreadyIsolatingScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AdviceForIndexCasesEnglandAlreadyIsolatingScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandAlreadyIsolatingScreen(app: app)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.body.exists)
            XCTAssertTrue(screen.furtherAdvice.exists)
            XCTAssertTrue(screen.nhsOnlineLink.exists)
            XCTAssertTrue(screen.continueButton.exists)

        }
    }

    func testNHSOnline() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandAlreadyIsolatingScreen(app: app)
            screen.nhsOnlineLink.tap()
            XCTAssertTrue(app.staticTexts[AdviceForIndexCasesEnglandAlreadyIsolatingScenario.ditTapNHSOnline].exists)
        }
    }

    func testContinueButton() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandAlreadyIsolatingScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[AdviceForIndexCasesEnglandAlreadyIsolatingScenario.didTapContinueButton].exists)
        }
    }
}

