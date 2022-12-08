//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingShareTestResultScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingShareTestResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingShareTestResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.subheader.exists)
            XCTAssertTrue(screen.body.exists)
            XCTAssertTrue(screen.privacyBox.exists)
            XCTAssertTrue(screen.bulletedListHeader.exists)
            XCTAssertTrue(screen.bulletedList.allExist)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testContinueButton() throws {
        try runner.run { app in
            let screen = SelfReportingShareTestResultScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}
