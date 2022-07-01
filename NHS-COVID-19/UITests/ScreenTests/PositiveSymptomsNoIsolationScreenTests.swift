//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class PositiveSymptomsNoIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<PositiveSymptomsNoIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveSymptomsNoIsolationScreen(app: app)

            XCTAssert(screen.heading.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.commonQuestionsButton.exists)
            XCTAssert(screen.furtherAdviceLabel.exists)
            XCTAssert(screen.nhs111OnlineLink.exists)
            XCTAssert(screen.backToHomeButton.exists)
        }
    }

    func testReturnHome() throws {
        try runner.run { app in
            let screen = PositiveSymptomsNoIsolationScreen(app: app)

            screen.backToHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }

    func testCommonQuestions() throws {
        try runner.run { app in
            let screen = PositiveSymptomsNoIsolationScreen(app: app)

            screen.commonQuestionsButton.tap()
            XCTAssert(screen.commonQuestionsAlertTitle.exists)
        }
    }

    func testNHS111Online() throws {
        try runner.run { app in
            let screen = PositiveSymptomsNoIsolationScreen(app: app)
            screen.nhs111OnlineLink.tap()
            XCTAssert(screen.nhs111OnlineAlertTitle.exists)
        }
    }
}

private extension PositiveSymptomsNoIsolationScreen {
    var commonQuestionsAlertTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsNoIsolationScreenScenario.commonQuestionsLinkTapped]
    }

    var nhs111OnlineAlertTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsNoIsolationScreenScenario.nhs111OnlineLinkTapped]
    }

    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[PositiveSymptomsNoIsolationScreenScenario.backHomeButtonTapped]
    }
}
