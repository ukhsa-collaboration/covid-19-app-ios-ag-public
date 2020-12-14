//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class FinancialSupportScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<FinanacialSupportScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = FinancialSupportScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.financialHelpEnglandLinkDescription.exists)
            XCTAssertTrue(screen.financialHelpEnglandLinkButton.exists)
            XCTAssertTrue(screen.financialHelpWalesLinkDescription.exists)
            XCTAssertTrue(screen.financialHelpWalesLinkButton.exists)
            XCTAssertTrue(screen.checkEligibilityLinkButton.exists)
        }
    }
    
    func testTapFinancialHelpEnglandLinkButton() throws {
        try runner.run { app in
            let screen = FinancialSupportScreen(app: app)
            
            screen.financialHelpEnglandLinkButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.financialHelpEnglandLinkAlertTitle].exists)
        }
    }
    
    func testTapFinancialHelpWalesLinkButton() throws {
        try runner.run { app in
            let screen = FinancialSupportScreen(app: app)
            
            screen.financialHelpWalesLinkButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.financialHelpWalesLinkAlertTitle].exists)
        }
    }
    
    func testCheckEligibilityLinkButton() throws {
        try runner.run { app in
            let screen = FinancialSupportScreen(app: app)
            
            screen.checkEligibilityLinkButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.checkYourEligibilityAlertTitle].exists)
        }
    }
}
