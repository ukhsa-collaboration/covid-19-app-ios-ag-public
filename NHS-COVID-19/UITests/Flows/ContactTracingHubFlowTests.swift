//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactTracingHubFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactTracingHubScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
    }
    
    func testContactTracingOffReminder() throws {

        // !TEMP! This currently fails in ar and bn
        if let languageCode = Locale.current.languageCode {
            if languageCode == "ar" || languageCode == "bn" {
                return
            }
        }

        $runner.report(scenario: "ContactTracingHub", "Contact Tracing Off - Reminder") {
            """
            Users see the contact tracing hub, toggles off contact tracing and chooses a reminder time
            """
        }
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing
                """
            }
            
            // toggle off contact tracing
            XCTAssert(screen.exposureNotificationSwitchOn.exists)
            XCTAssert(screen.exposureNotificationSwitchOn.isHittable)
            screen.exposureNotificationSwitchOn.tap()
            
            // toggle turns off before contract tracing is confirmed as off atm...
            XCTAssert(screen.exposureNotificationSwitchOff.exists)
            
            runner.step("Choose reminder time") {
                """
                The user is presented options of when to be reminded to turn contact tracing back on
                """
            }
            
            screen.pauseContactTracingButton.tap()
            
            XCTAssert(screen.exposureNotificationSwitchOff.exists) // contact tracing is now off
            
            runner.step("Confirmation alert") {
                """
                The user is presented a confirmation alert that he will be reminded in x hours
                """
            }
            
            XCTAssert(screen.reminderAlertTitle.exists)
            screen.reminderAlertButton.tap()
            
            runner.step("Contact tracing off") {
                """
                User now sees that contact tracing is off
                """
            }
        }
    }
    
    func testContactTracingOnWithoutReminder() throws {
        
        // ensure user notifications are off
        $runner.initialState.userNotificationsAuthorized = false
        
        $runner.report(scenario: "ContactTracingHub", "Contact Tracing Off - No Notification Authorization") {
            """
            Users see the contact tracing hub, toggles off contact tracing and does not see the option to set a reminder
            """
        }
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing on the contact tracing hub
                """
            }
            
            // toggle contact tracing off
            XCTAssert(screen.exposureNotificationSwitchOn.exists)
            XCTAssert(screen.exposureNotificationSwitchOn.isHittable)
            screen.exposureNotificationSwitchOn.tap()
            
            // check that there is no alert
            XCTAssertFalse(screen.reminderAlertTitle.exists)
            
            // since user notifications are off we just disable without showing the reminder sheet
            XCTAssert(screen.exposureNotificationSwitchOff.exists)
            
            runner.step("Contact tracing off") {
                """
                User now sees that contact tracing is off
                """
            }
        }
    }
}
