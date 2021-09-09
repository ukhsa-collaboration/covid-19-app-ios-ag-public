//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseNoIsolationMedicallyExemptScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationMedicallyExemptScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            for element in screen.allElements {
                app.scrollTo(element: element)
                XCTAssertTrue(element.exists)
            }
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testCommonQuestionsLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            screen.commonQuestionsLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsLinkTapped].exists)
        }
    }
    
    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            app.scrollTo(element: screen.bookAFreeTestButton)
            screen.bookAFreeTestButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
