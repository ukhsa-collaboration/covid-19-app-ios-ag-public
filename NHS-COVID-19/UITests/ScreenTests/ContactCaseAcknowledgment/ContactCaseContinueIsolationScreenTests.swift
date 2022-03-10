//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseContinueIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseContinueIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseContinueIsolationScreen(app: app)
            XCTAssertTrue(screen.daysRemanining(with: runner.scenario.numberOfDays).exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseContinueIsolationScreen(app: app)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testGetBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseContinueIsolationScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
