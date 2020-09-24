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
    }
    
    func testHappyPath() throws {
        $runner.report(scenario: "HomeFlow", "Happy path") {
            """
            Users see the home screen and navigates to the different subpages
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            XCTAssert(homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).exists)
            
            runner.step("More Info") {
                """
                Users can go to Risk level more info screen
                """
            }
            homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).tap()
            app.buttons[localize(.risk_level_screen_close_button)].tap()
            
            runner.step("Diagnosis") {
                """
                Users can navigate to self diagnosis page
                """
            }
            homeScreen.diagnoisButton.tap()
            
            app.buttons[localize(.cancel)].tap()
            
            runner.step("Check-In") {
                """
                Users can navigate to checkin page
                """
            }
            
            homeScreen.checkInButton.tap()
            
            app.buttons[localize(.checkin_qrcode_scanner_close_button_title)].tap()
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing
                """
            }
            
            runner.step("About") {
                """
                Users can navigate to about page
                """
            }
            homeScreen.aboutButton.tap()
            
            app.buttons[localize(.back)].tap()
            
        }
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
            
            XCTAssert(homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).exists)
            
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
            
            XCTAssert(homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).exists)
            
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
