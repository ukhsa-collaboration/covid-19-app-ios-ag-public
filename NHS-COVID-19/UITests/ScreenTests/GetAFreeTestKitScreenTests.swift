//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GetAFreeTestKitScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<GetAFreeTestKitScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = GetAFreeTestKitScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.submitButton.exists)
            XCTAssertTrue(screen.cancelButton.exists)
        }
    }
    
    func testBookARapidTest() throws {
        try runner.run { app in
            let screen = GetAFreeTestKitScreen(app: app)
            screen.submitButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestTapped].exists)
        }
    }
    
    func testCancel() throws {
        try runner.run { app in
            let screen = GetAFreeTestKitScreen(app: app)
            screen.cancelButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.cancelTapped].exists)
        }
    }
}
