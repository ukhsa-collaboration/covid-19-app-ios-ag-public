//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class NoSymptomsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<NoSymptomsViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = NoSymptomsScreen(app: app)
            
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.description1.exists)
            XCTAssert(screen.description2.exists)
            XCTAssert(screen.link.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapReturnHome() throws {
        try runner.run { app in
            let screen = NoSymptomsScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeButtonAlertTitle.exists)
        }
    }
    
    func testNHS111LinkTapped() throws {
        try runner.run { app in
            let screen = NoSymptomsScreen(app: app)
            
            screen.link.tap()
            XCTAssert(screen.nhs111LinkAlertTitle.exists)
        }
    }
    
}
