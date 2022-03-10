//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseNoIsolationAdviceScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationAdviceScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationAdviceScreen(app: app)
            for element in screen.allElements {
                app.scrollTo(element: element)
                XCTAssertTrue(element.exists, "Could not found \(element)")
            }
        }
    }
    
    func testHouseholdContactsGuidanceLink() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationAdviceScreen(app: app)
            app.scrollTo(element: screen.householdContactsGuidanceLink)
            screen.householdContactsGuidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkForHouseholdContactsTapped].exists)
        }
    }
    
    func testContactsGuidanceLink() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationAdviceScreen(app: app)
            app.scrollTo(element: screen.contactsGuidanceLink)
            screen.contactsGuidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkForContactsTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationAdviceScreen(app: app)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
