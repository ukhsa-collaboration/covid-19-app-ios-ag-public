//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfIsolationHubScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SelfIsolationHubScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            
            XCTAssertTrue(screen.bookFreeTestButton.exists)
            XCTAssertTrue(screen.financialSupportButton.exists)
            XCTAssertTrue(screen.howToSelfIsolateAccordionTitleButton.exists)
            XCTAssertTrue(screen.practicalSupportAccordionTitleButton.exists)
            XCTAssertFalse(screen.readLatestGovenrnmentGuidanceLink.exists)
            XCTAssertFalse(screen.findYourLocalAuthorityLink.exists)
        }
    }
    
    func testBookFreeTestButton() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            screen.bookFreeTestButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestAlertTitle].exists)
        }
    }
    
    func testFinancialSupportButton() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            screen.financialSupportButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.financialSupportAlertTitle].exists)
        }
    }
    
    func testReadLatestGovenrnmentGuidanceLinkInsideHowToSelfIsolateAccordion() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            
            // expand 'How to self-isolate' accordion
            XCTAssert(screen.howToSelfIsolateAccordionTitleButton.exists)
            XCTAssert(screen.howToSelfIsolateAccordionTitleButton.isHittable)
            screen.howToSelfIsolateAccordionTitleButton.tap()
            
            // tap on link
            app.scrollTo(element: screen.readLatestGovenrnmentGuidanceLink)
            XCTAssert(screen.readLatestGovenrnmentGuidanceLink.exists)
            XCTAssert(screen.readLatestGovenrnmentGuidanceLink.isHittable)
            screen.readLatestGovenrnmentGuidanceLink.tap()
            
            XCTAssert(app.staticTexts[runner.scenario.readGovernmentGuidanceAlertTitle].displayed)
        }
    }
    
    func testFindYourLocalAuthorityLinkInsideHowToSelfIsolateAccordion() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            
            // expand 'How to self-isolate' accordion
            XCTAssert(screen.howToSelfIsolateAccordionTitleButton.exists)
            XCTAssert(screen.howToSelfIsolateAccordionTitleButton.isHittable)
            screen.howToSelfIsolateAccordionTitleButton.tap()
            
            // tap on link
            app.scrollTo(element: screen.findYourLocalAuthorityLink)
            XCTAssert(screen.findYourLocalAuthorityLink.exists)
            XCTAssert(screen.findYourLocalAuthorityLink.isHittable)
            screen.findYourLocalAuthorityLink.tap()
            
            XCTAssert(app.staticTexts[runner.scenario.findYourLocalAuthorityAlertTitle].displayed)
        }
    }
    
    func testFindYourLocalAuthorityLinkInsidePracticalSupportAccordion() throws {
        try runner.run { app in
            let screen = SelfIsolationHubScreen(app: app)
            
            // expand 'Practical support while you are self-isolating' accordion
            XCTAssert(screen.practicalSupportAccordionTitleButton.exists)
            XCTAssert(screen.practicalSupportAccordionTitleButton.isHittable)
            screen.practicalSupportAccordionTitleButton.tap()
            
            // tap on link
            app.scrollTo(element: screen.findYourLocalAuthorityLink)
            XCTAssert(screen.findYourLocalAuthorityLink.exists)
            XCTAssert(screen.findYourLocalAuthorityLink.isHittable)
            screen.findYourLocalAuthorityLink.tap()
            
            XCTAssert(app.staticTexts[runner.scenario.findYourLocalAuthorityAlertTitle].displayed)
        }
    }
    
}
