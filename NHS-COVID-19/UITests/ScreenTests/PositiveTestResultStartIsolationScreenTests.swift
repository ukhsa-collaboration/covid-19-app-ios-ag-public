//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class PositiveTestResultStartIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<PositiveTestResultStartIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)
            XCTAssert(screen.daysIsolateLabel(daysRemaining: runner.scenario.daysToIsolate).exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabels.allExist)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }

    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)

            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }

    func testShareKeys() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)

            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
}

private extension PositiveTestResultStartIsolationScreen {

    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.onlineServicesLinkTapped]
    }

    var exposureFAQLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.exposureFAQLinkTapped]
    }

    var continueAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.primaryButtonTapped]
    }

    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.noThanksLinkTapped]
    }

}
