//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class HomeFlowTests: XCTestCase {
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
    }
        
    func testContactTracingReenableSwitch() throws {
        
        $runner.initialState.exposureNotificationsEnabled = false
        
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreen(postcode: postcode)

            runner.step("Enable Contact tracing") {
                """
                Users can enable contact tracing on the homescreen
                """
            }

            // locate the 'Turn back on' button and tap
            XCTAssert(homeScreen.turnContactTracingBackOnButton.exists)
            XCTAssert(homeScreen.turnContactTracingBackOnButton.isHittable)
            homeScreen.turnContactTracingBackOnButton.tap()
            
            // check the button is gone
            XCTAssertFalse(homeScreen.turnContactTracingBackOnButton.exists)
            
            runner.step("Contact tracing on") {
                """
                User now sees that contact tracing is back on
                """
            }
        }
    }
    
    func testDailyContactTestingOnIfFeatureFlagEnabled() throws {
        
        // turn dct feature on
        $runner.enable(\.$dailyContactTestingToggle)
        
        // put user into isolation
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        
        $runner.report(scenario: "HomeFlow", "Daily Contact Testing On") {
            """
            Users see the Daily Contact Testing checkbox on the test entry screen
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreen(postcode: postcode)
            
            app.scrollTo(element: homeScreen.enterTestResultButton)
            homeScreen.enterTestResultButton.tap()
            
            let linkTestResult = LinkTestResultWithDCTScreen(app: app)
            
            linkTestResult.checkBox(checked: false).tap()
            
            linkTestResult.continueButton.tap()
            
            let dailyConfirmationScreen = DailyContactTestingConfirmationScreen(app: app)
            
            XCTAssert(dailyConfirmationScreen.confirmButton.exists)
            
            dailyConfirmationScreen.confirmButton.tap()
            
            XCTAssert(dailyConfirmationScreen.confirmAlert.exists)
            
            runner.step("User saw confirm alert") {
                """
                User now sees the daily contact testing confirm screen
                """
            }
        }
    }
}
