//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseNoIsolationFullyVaccinatedEnglandScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedEnglandScreen(app: app)
            for element in screen.allElements {
                XCTAssertTrue(element.exists, "Could not find: \(element)")
            }
        }
    }
    
    
    func testReadGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedEnglandScreen(app: app)
            app.scrollTo(element: screen.readGuidanceLinkButton)
            screen.readGuidanceLinkButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.readGuidanceLinkTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedEnglandScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}

class ContactCaseNoIsolationFullyVaccinatedWalesScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedWalesScreen(app: app)
            XCTAssertTrue(screen.commonQuestionsLink.exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.lfdListItem.exists)
            XCTAssertTrue(screen.secondTestAdviceListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedWalesScreen(app: app)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testCommonQuestionsLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedWalesScreen(app: app)
            screen.commonQuestionsLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsLinkTapped].exists)
        }
    }
    
    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedWalesScreen(app: app)
            app.scrollTo(element: screen.bookAFreeTestButton)
            screen.bookAFreeTestButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationFullyVaccinatedWalesScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
