//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class StartOnboardingScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<StartOnboardingScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            
            XCTAssert(screen.stepTitle.exists)
            XCTAssert(screen.stepDescription1Header.exists)
            XCTAssert(screen.stepDescription1Body.exists)
            XCTAssert(screen.stepDescription2Header.exists)
            XCTAssert(screen.stepDescription2Body.exists)
            XCTAssert(screen.stepDescription3Header.exists)
            XCTAssert(screen.stepDescription3Body.exists)
            XCTAssert(screen.stepDescription4Header.exists)
            XCTAssert(screen.stepDescription4Body.exists)
            XCTAssert(screen.continueButton.exists)
            
        }
    }
    
    func testComplete() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            
            let completeAction = app.staticTexts[StartOnboardingScreenScenario.continueConfirmationAlertTitle]
            
            screen.continueButton.tap()
            XCTAssert(completeAction.displayed)
            
        }
    }
    
}
