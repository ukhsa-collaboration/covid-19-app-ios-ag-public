//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class AuthorizationDeniedScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<AuthorizationDeniedScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = AuthorizationDeniedScreen(app: app)
            
            XCTAssert(screen.errorTitle.exists)
            XCTAssert(screen.description.allExist)
            XCTAssert(screen.settingsButton.exists)
        }
    }
    
    func testContinueButton() throws {
        try runner.run { app in
            let screen = AuthorizationDeniedScreen(app: app)
            
            XCTAssert(screen.errorTitle.exists)
            
            screen.settingsButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.openSettingsTapped].exists)
        }
    }
}
