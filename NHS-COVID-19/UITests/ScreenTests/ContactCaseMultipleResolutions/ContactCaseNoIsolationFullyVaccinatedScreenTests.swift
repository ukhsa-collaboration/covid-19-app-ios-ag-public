//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseNoIsolationFullyVaccinatedScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationFullyVaccinatedScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            XCTAssertTrue(screen.commonQuestionsLink.exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.lfdListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testCommonQuestionsLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            screen.commonQuestionsLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsLinkTapped].exists)
        }
    }
    
    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            app.scrollTo(element: screen.bookAFreeTestButton)
            screen.bookAFreeTestButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
