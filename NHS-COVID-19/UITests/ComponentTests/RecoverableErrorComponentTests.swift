//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class RecoverableErrorComponentTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<RecoverableErrorScreenTemplateScenario>

    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.stepTitle.exists)
            XCTAssert(app.customContent.exists)
            XCTAssert(app.customContent2.exists)
            XCTAssert(app.actionButton.exists)
        }
    }

    func testAction() throws {
        try runner.run { app in
            app.actionButton.tap()
            XCTAssert(app.actionResult.exists)
        }
    }

    func testSecondaryAction() throws {
        try runner.run { app in
            app.secondaryActionButton.tap()
            XCTAssert(app.secondaryButtonActionResult.exists)
        }
    }

}

private extension XCUIApplication {

    var stepTitle: XCUIElement {
        staticTexts[RecoverableErrorScreenTemplateScenario.errorTitle]
    }

    var actionButton: XCUIElement {
        buttons[RecoverableErrorScreenTemplateScenario.actionTitle]
    }

    var secondaryActionButton: XCUIElement {
        buttons[RecoverableErrorScreenTemplateScenario.secondaryActionTitle]
    }

    var customContent: XCUIElement {
        staticTexts[RecoverableErrorScreenTemplateScenario.customViewContent]
    }

    var customContent2: XCUIElement {
        staticTexts[RecoverableErrorScreenTemplateScenario.customViewContent2]
    }

    var actionResult: XCUIElement {
        staticTexts[RecoverableErrorScreenTemplateScenario.didPerformActionTitle]
    }

    var secondaryButtonActionResult: XCUIElement {
        staticTexts[RecoverableErrorScreenTemplateScenario.didPerformSecondaryActionTitle]
    }

}
