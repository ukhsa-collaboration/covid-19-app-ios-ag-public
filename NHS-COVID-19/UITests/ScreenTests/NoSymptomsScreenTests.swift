//
// Copyright © 2021 DHSC. All rights reserved.
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
            
            screen.stillGetTestBodyElements.forEach { XCTAssert($0.exists) }
            XCTAssert(screen.gettingTestedLink.exists)
            
            screen.developSymptomsBodyElements.forEach { XCTAssert($0.exists) }
            XCTAssert(screen.nhs111Link.exists)
            
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
    
    func testGettingTestedLinkTapped() throws {
        try runner.run { app in
            let screen = NoSymptomsScreen(app: app)
            
            screen.gettingTestedLink.tap()
            XCTAssert(screen.gettingTestedLinkAlertTitle.exists)
        }
    }
    
    func testNHS111LinkTapped() throws {
        try runner.run { app in
            let screen = NoSymptomsScreen(app: app)
            
            screen.nhs111Link.tap()
            XCTAssert(screen.nhs111LinkAlertTitle.exists)
        }
    }
    
}
