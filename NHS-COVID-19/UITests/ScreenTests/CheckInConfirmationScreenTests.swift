//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class CheckInConfirmationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<CheckInConfirmationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = CheckInConfirmationScreen(app: app)

            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.homeButton.exists)
            XCTAssertTrue(screen.wrongButton.exists)
            XCTAssertTrue(screen.dateTime(CheckInConfirmationScreenScenario.checkinDate).exists)
            XCTAssertTrue(screen.thankYouText(with: CheckInConfirmationScreenScenario.venueName).exists)
        }
    }

    func testTapHomeButton() throws {
        try runner.run { app in
            let screen = CheckInConfirmationScreen(app: app)
            screen.homeButton.tap()
            XCTAssertTrue(screen.homeAlert.exists)
        }
    }

    func testTapWrongButton() throws {
        try runner.run { app in
            let screen = CheckInConfirmationScreen(app: app)
            screen.wrongButton.tap()
            XCTAssertTrue(screen.wrongAlert.exists)
        }
    }
}
