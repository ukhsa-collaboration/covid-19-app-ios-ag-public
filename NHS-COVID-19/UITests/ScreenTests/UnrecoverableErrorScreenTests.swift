//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class UnrecoverableErrorScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<UnrecoverableErrorScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = UnrecoverableErrorScreen(app: app)
            
            XCTAssert(screen.heading1.exists)
            XCTAssert(screen.heading2.exists)
            XCTAssert(screen.bulletedList.allExist)
            XCTAssert(screen.description2.exists)
            XCTAssert(screen.link.exists)
            
        }
        
    }
    
    func testLinkTapped() throws {
        try runner.run { app in
            let screen = UnrecoverableErrorScreen(app: app)
            
            screen.link.tap()
            XCTAssert(screen.linkAlertTitle.exists)
        }
    }
    
}
