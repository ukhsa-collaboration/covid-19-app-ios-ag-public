//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class IsolationPaymentFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "Sheffield"
    }
    
    func testHappyPath() throws {
        
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.isolationPaymentState = Sandbox.Text.IsolationPaymentState.enabled.rawValue
        
        $runner.report(scenario: "Apply for financial support", "Happy path") {
            """
            Condition 1: Users is as contact case in isolation.
            Condition 2: Users should not have a positve test results.
            Condition 3: Financial support is enabled.
            Users can apply for financial support and gets redirected to the isolation payment application form on a web browser.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreen(with: homeScreen.financeButton)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the Financial support button.
                """
            }
            
            app.scrollTo(element: homeScreen.financeButton)
            homeScreen.financeButton.tap()
            
            let financialSupportScreen = FinancialSupportScreen(app: app)
            XCTAssert(financialSupportScreen.checkEligibilityLinkButton.exists)
            
            runner.step("Financial support screen") {
                """
                The user is presented the financial support screen.
                The user presses the check eligibility button
                """
            }
            
            financialSupportScreen.checkEligibilityLinkButton.tap()
            
            runner.step("Home screen - after financial suppport") {
                """
                The user is redirected to the isolation payment application form on a web browser.
                The user is presented the home screen again.
                """
            }
            
        }
    }
}
