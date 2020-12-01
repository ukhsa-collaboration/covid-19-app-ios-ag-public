//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LocalAuthorityInformationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LocalAuthorityInformationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = LocalAuthorityScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.button.exists)
        }
    }
    
    func testContinue() throws {
        try runner.run { app in
            let screen = LocalAuthorityScreen(app: app)
            screen.button.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.continueTapped].exists)
        }
    }
}
