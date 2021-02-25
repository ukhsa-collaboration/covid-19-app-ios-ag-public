//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class DailyContactTestingConfirmationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<DailyContactTestingConfirmationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = DailyContactTestingConfirmationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.description.exists)
            XCTAssert(screen.bulletedListContinueHeading.exists)
            XCTAssert(screen.bulletedListContinue.allExist)
            XCTAssert(screen.bulletedListNoLongerHeading.exists)
            XCTAssert(screen.bulletedListNoLonger.allExist)
            
        }
    }
    
    func testConfirmButton() throws {
        try runner.run { app in
            let screen = DailyContactTestingConfirmationScreen(app: app)
            
            XCTAssert(screen.confirmButton.exists)
            
            screen.confirmButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.confirmButtonTapped].exists)
        }
    }
}
