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
                XCTAssertTrue(element.exists, "Could not found \(element)")
            }
        }
    }
    
    func testReadGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            app.scrollTo(element: screen.readGuidanceLinkButton)
            screen.readGuidanceLinkButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.readGuidanceLinkTapped].exists)
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
