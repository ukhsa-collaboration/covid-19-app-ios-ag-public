//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

import Foundation

class NegativeAfterPositiveTestResultScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<NegativeTestResultAfterPositiveWithIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = NegativeAfterPositiveTestResultScreen(app: app)

            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }

    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = NegativeAfterPositiveTestResultScreen(app: app)

            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }

    func testReturnHome() throws {
        try runner.run { app in
            let screen = NegativeAfterPositiveTestResultScreen(app: app)

            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
}

private extension NegativeAfterPositiveTestResultScreen {

    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultAfterPositiveWithIsolationScreenScenario.onlineServicesLinkTapped]
    }

    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultWithIsolationScreenScenario.returnHomeTapped]
    }
}
