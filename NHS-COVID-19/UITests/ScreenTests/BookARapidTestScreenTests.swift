//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class BookARapidTestScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<BookARapidTestInfoScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = BookARapidTestScreen(app: app)
            XCTAssertTrue(screen.title.exists)

            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.submitButton.exists)
            XCTAssertTrue(screen.cancelButton.exists)
        }
    }

    func testBookARapidTest() throws {
        try runner.run { app in
            let screen = BookARapidTestScreen(app: app)
            screen.submitButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestTapped].exists)
        }
    }

    func testCancel() throws {
        try runner.run { app in
            let screen = BookARapidTestScreen(app: app)
            screen.cancelButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.cancelTapped].exists)
        }
    }
}
