//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class RiskyVenueInformationBookATestScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskyVenueInformationBookATestScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.info.exists)
            XCTAssertTrue(screen.bulletedList.allExist)
            XCTAssertTrue(screen.bookATestButton.exists)
            XCTAssertTrue(screen.bookATestLaterButton.exists)
            XCTAssertTrue(screen.closeButton.exists)
        }
    }
    
    func testBookATestButton() throws {
        try runner.run { app in
            let screen = RiskyVenueInformationBookATestScreen(app: app)
            screen.bookATestButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestTapped].exists)
        }
    }
    
    func testBookATestLaterButtonTapped() throws {
        try runner.run { app in
            let screen = RiskyVenueInformationBookATestScreen(app: app)
            screen.bookATestLaterButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestLaterTapped].exists)
        }
    }
    
    func testCloseButtonTapped() throws {
        try runner.run { app in
            let screen = RiskyVenueInformationBookATestScreen(app: app)
            screen.closeButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.closeTapped].exists)
        }
    }
    
}
