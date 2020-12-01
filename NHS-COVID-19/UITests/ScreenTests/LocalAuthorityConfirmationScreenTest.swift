//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LocalAuthorityConfirmationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LocalAuthorityConfirmationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = LocalAuthorityConfirmationScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            let heading = screen.heading(postcode: runner.scenario.postcode, localAuthority: runner.scenario.localAuthority.name)
            XCTAssertTrue(heading.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.button.exists)
        }
    }
    
    func testContinue() throws {
        try runner.run { app in
            let screen = LocalAuthorityConfirmationScreen(app: app)
            screen.button.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.confirmTapped].exists)
        }
    }
}
