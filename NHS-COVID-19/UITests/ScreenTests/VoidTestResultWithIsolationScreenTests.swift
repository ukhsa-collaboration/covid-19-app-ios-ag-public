//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class VoidTestResultWithIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<VoidTestResultWithIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)
            XCTAssert(screen.daysIsolateLabel(daysRemaining: runner.scenario.daysToIsolate).exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.nhsGuidanceLink.exists)
            XCTAssert(screen.primaryButton.exists)
        }
    }

    func testTapNHSGuidance() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)

            screen.nhsGuidanceLink.tap()
            XCTAssert(screen.nhsGuidanceLinkAlertTitle.exists)
        }
    }

    func testPrimaryButtonTap() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)

            screen.primaryButton.tap()
            XCTAssert(screen.primaryButtonAlertTitle.exists)
        }
    }
}

private extension VoidTestResultWithIsolationScreen {

    var nhsGuidanceLinkAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.nhsGuidanceLinkTapped]
    }

    var primaryButtonAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.primaryButtonTapped]
    }

    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.noThanksLinkTapped]
    }

}
