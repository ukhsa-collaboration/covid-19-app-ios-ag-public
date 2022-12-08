//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingWillNotNotifyOthersScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingWillNotNotifyOthersScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingWillNotNotifyOthersScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.body.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testContinueButton() throws {
        try runner.run { app in
            let screen = SelfReportingWillNotNotifyOthersScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}
