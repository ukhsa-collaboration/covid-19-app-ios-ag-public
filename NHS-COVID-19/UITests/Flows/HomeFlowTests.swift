//
// Copyright © 2020 NHSX. All rights reserved.
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
    
    func testContactTracingOffReminder() throws {
        $runner.initialState.userNotificationsAuthorized = true
        
        $runner.report(scenario: "HomeFlow", "Contact Tracing Off - Reminder") {
            """
            Users see the home screen, toggles off contact tracing and chooses a reminder time
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreen(postcode: postcode)
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing
                """
            }
            
            XCTAssert(homeScreen.exposureNotificationSwitch.exists)
            
            app.scrollTo(element: homeScreen.exposureNotificationSwitch)
            XCTAssert(homeScreen.exposureNotificationSwitch.isHittable)
            
            homeScreen.exposureNotificationSwitch.tap()
            
            XCTAssert(homeScreen.disabledContactTracing.exists)
            
            runner.step("Choose reminder time") {
                """
                The user is presented options of when to be reminded to turn contact tracing back on
                """
            }
            
            homeScreen.pauseContactTracingButton.tap()
            
            runner.step("Confirmation alert") {
                """
                The user is presented a confirmation alert that he will be reminded in x hours
                """
            }
            
            XCTAssert(homeScreen.reminderAlertTitle.exists)
            homeScreen.reminderAlertButton.tap()
            
            runner.step("Contact tracing off") {
                """
                User now sees that contact tracing is off
                """
            }
        }
    }
    
    func testContactTracingOffWithoutReminder() throws {
        
        $runner.report(scenario: "HomeFlow", "Contact Tracing Off - No Notification Authorization") {
            """
            Users see the home screen, toggles off contact tracing and does not see the option to set a reminder
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreen(postcode: postcode)
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing on the homescreen
                """
            }
            
            XCTAssert(homeScreen.exposureNotificationSwitch.exists)
            
            app.scrollTo(element: homeScreen.exposureNotificationSwitch)
            XCTAssert(homeScreen.exposureNotificationSwitch.isHittable)
            
            homeScreen.exposureNotificationSwitch.tap()
            
            XCTAssert(homeScreen.disabledContactTracing.exists)
            
            runner.step("Contact tracing off") {
                """
                User now sees that contact tracing is off
                """
            }
        }
    }
}
