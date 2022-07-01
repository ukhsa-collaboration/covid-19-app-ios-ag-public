//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PositiveSymptomsScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<PositiveSymptomsScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveSymptomsScreen(app: app)

            XCTAssert(screen.pleaseIsolateLabel.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.getRapidLateralFlowTestButton.exists)
            XCTAssert(screen.furtherAdviceButton.exists)
            XCTAssert(screen.exposureFAQLink.exists)
        }
    }

    func testReturnHome() throws {
        try runner.run { app in
            let screen = PositiveSymptomsScreen(app: app)

            screen.getRapidLateralFlowTestButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }

    func testFurtherAdvice() throws {
        try runner.run { app in
            let screen = PositiveSymptomsScreen(app: app)

            screen.furtherAdviceButton.tap()
            XCTAssert(screen.furtherAdviceAlertTitle.exists)
        }
    }

    func testExposureFAQ() throws {
        try runner.run { app in
            let screen = PositiveSymptomsScreen(app: app)
            screen.exposureFAQLink.tap()
            XCTAssert(screen.exposureFAQTappedTitle.exists)
        }
    }
}

private extension PositiveSymptomsScreen {
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsScreenScenario.getAFreeRapidLateralFlowTestTapped]
    }

    var furtherAdviceAlertTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsScreenScenario.furtherAdviceTapped]
    }

    var exposureFAQTappedTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsScreenScenario.exposureFAQstapped]
    }
}
