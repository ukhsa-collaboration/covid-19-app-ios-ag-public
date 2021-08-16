//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfIsolationHubFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "Sheffield"
    }
    
    func testFinancialSupport() throws {
        
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.isolationPaymentState = Sandbox.Text.IsolationPaymentState.enabled.rawValue
        
        $runner.report(scenario: "Apply for financial support", "Happy path") {
            """
            Condition 1: Users is as contact case in isolation.
            Condition 2: Users should not have a positive test results.
            Condition 3: Financial support is enabled.
            Users can apply for financial support and gets redirected to the isolation payment application form on a web browser.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreen(with: homeScreen.selfIsolationHubButton)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the Self-isolation button.
                """
            }
            
            homeScreen.selfIsolationHubButton.tap()
            
            let selfIsolationHubScreen = SelfIsolationHubScreen(app: app)
            XCTAssert(selfIsolationHubScreen.financialSupportButton.exists)
            
            runner.step("Self-isolation Hub screen") {
                """
                The user is presented the Self-isolation Hub screen.
                The user presses the check if available for financial support button
                """
            }
            
            selfIsolationHubScreen.financialSupportButton.tap()
            
            let financialSupportScreen = FinancialSupportScreen(app: app)
            XCTAssert(financialSupportScreen.checkEligibilityLinkButton.exists)
            
            runner.step("Financial support screen") {
                """
                The user is presented the financial support screen.
                The user presses the check eligibility button
                """
            }
            
            financialSupportScreen.checkEligibilityLinkButton.tap()
            XCTAssert(homeScreen.aboutButton.waitForExistence(timeout: 0.1))
            
            runner.step("Home screen - after financial suppport") {
                """
                The user is redirected to the isolation payment application form on a web browser.
                The user is presented the home screen again.
                """
            }
            
        }
    }
    
    func testBookAFreeTest() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        
        $runner.report(scenario: "Book a free test", "Happy path") {
            """
            Condition: Users is as contact case in isolation.
            Users can book a free test and gets redirected to the book a test application form on a web browser.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreen(with: homeScreen.selfIsolationHubButton)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the Self-isolation button.
                """
            }
            
            homeScreen.selfIsolationHubButton.tap()
            
            let selfIsolationHubScreen = SelfIsolationHubScreen(app: app)
            XCTAssertFalse(selfIsolationHubScreen.financialSupportButton.exists)
            XCTAssertTrue(selfIsolationHubScreen.bookFreeTestButton.exists)
            
            runner.step("Self-isolation Hub screen") {
                """
                The user is presented the Self-isolation Hub screen.
                Screen should have book a free test button
                Screen should not have financial support button
                The user presses the book a free test button
                """
            }
            
            selfIsolationHubScreen.bookFreeTestButton.tap()
            
            let bookATestScreen = BookATestScreen(app: app)
            XCTAssertTrue(bookATestScreen.button.exists)
            
            runner.step("Book A Test Info screen") {
                """
                The user is presented the Book A Test Info screen.
                Screen should have book a test for yourself button
                The user presses the book a test for yourself button
                """
            }
            
            bookATestScreen.button.tap()
            XCTAssert(homeScreen.aboutButton.waitForExistence(timeout: 0.1))
            
            runner.step("Home screen - after booking a free test") {
                """
                The user is redirected to the book a free test form on a web browser.
                The user is presented the home screen again.
                """
            }
        }
    }
    
}
