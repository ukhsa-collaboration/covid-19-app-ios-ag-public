//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseStartIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseStartIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseStartIsolationScreen(app: app)
            XCTAssertTrue(screen.daysRemanining(with: runner.scenario.numberOfDays).exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.lfdListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseStartIsolationScreen(app: app)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseStartIsolationScreen(app: app)
            screen.bookAFreeTestButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseStartIsolationScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
