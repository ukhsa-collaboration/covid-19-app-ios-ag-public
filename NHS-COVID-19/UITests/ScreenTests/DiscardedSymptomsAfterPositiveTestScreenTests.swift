//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class DiscardedSymptomsAfterPositiveTestScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<DiscardedSymptomsAfterPositiveScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = DiscardedSymptomsAfterPositiveTestScreen(app: app)
            
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.info.exists)
            XCTAssert(screen.body.allExist)
            XCTAssert(screen.advice.exists)
            XCTAssert(screen.nhs111Link.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapReturnHome() throws {
        try runner.run { app in
            let screen = DiscardedSymptomsAfterPositiveTestScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeButtonAlertTitle.exists)
        }
    }
    
    func testNHS111LinkTapped() throws {
        try runner.run { app in
            let screen = DiscardedSymptomsAfterPositiveTestScreen(app: app)
            
            screen.nhs111Link.tap()
            XCTAssert(screen.nhs111LinkAlertTitle.exists)
        }
    }
    
}
