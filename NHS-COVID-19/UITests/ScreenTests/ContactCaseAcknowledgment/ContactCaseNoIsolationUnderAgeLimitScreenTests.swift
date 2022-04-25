//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseNoIsolationUnderAgeLimitEnglandScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitEnglandScreen(app: app)
            for element in screen.allElements {
                XCTAssertTrue(element.exists, "Could not find: \(element)")
            }
        }
    }
    
    func testReadGuidanceTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitEnglandScreen(app: app)
            app.scrollTo(element: screen.readGuidanceButton)
            screen.readGuidanceButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.contactGuidanceButtonTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitEnglandScreen(app: app)
            app.scrollTo(element: screen.backToHomeButton)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}

class ContactCaseNoIsolationUnderAgeLimitWalesScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitWalesScreen(app: app)
            XCTAssertTrue(screen.commonQuestionsLink.exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.lfdListItem.exists)
            XCTAssertTrue(screen.secondTestDateListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }
    
    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitWalesScreen(app: app)
            app.scrollTo(element: screen.guidanceLink)
            screen.guidanceLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }
    
    func testCommonQuestionsLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitWalesScreen(app: app)
            app.scrollTo(element: screen.commonQuestionsLink)
            screen.commonQuestionsLink.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsLinkTapped].exists)
        }
    }
    
    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitWalesScreen(app: app)
            app.scrollTo(element: screen.bookAFreeTestButton)
            screen.bookAFreeTestButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = ContactCaseNoIsolationUnderAgeLimitWalesScreen(app: app)
            app.scrollTo(element: screen.backToHomeButton)
            screen.backToHomeButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}
