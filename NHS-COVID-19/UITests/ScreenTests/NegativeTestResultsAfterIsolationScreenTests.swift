//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class NegativeTestResultNoIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<NegativeTestResultNoIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = NegativeTestResultNoIsolationScreen(app: app)

            XCTAssert(screen.title.exists)
            XCTAssert(screen.description.exists)
            XCTAssert(screen.warning.exists)
            XCTAssert(screen.linkHint.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }

    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = NegativeTestResultNoIsolationScreen(app: app)

            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }

    func testReturnHome() throws {
        try runner.run { app in
            let screen = NegativeTestResultNoIsolationScreen(app: app)

            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
}
