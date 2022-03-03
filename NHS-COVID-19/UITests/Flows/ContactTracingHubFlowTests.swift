//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactTracingHubFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
    }
    
    func testContactTracingOffReminder() throws {
        $runner.report(scenario: "Contact Tracing Hub", "Contact Tracing Off - Reminder") {
            """
            Users tap on the Manage contact tracing button in the Home screen,
            Users see the Contact Tracing Hub,
            Users toggle off contact tracing and choose a reminder time.
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.contactTracingHubButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on manage contact tracing button.
                """
            }
            
            app.scrollTo(element: homeScreen.contactTracingHubButton)
            homeScreen.contactTracingHubButton.tap()
            
            let contactTracingHubScreen = ContactTracingHubScreen(app: app)
            
            runner.step("Disable Contact tracing") {
                """
                The user is presented the Contact Tracing Hub screen.
                Users can disable contact tracing
                """
            }
            
            // toggle off contact tracing
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOn.exists)
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOn.isHittable)
            contactTracingHubScreen.toggleOffSwitch()
            
            // toggle turns off before contract tracing is confirmed as off atm...
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOff.exists)
            
            runner.step("Choose reminder time") {
                """
                The user is presented options of when to be reminded to turn contact tracing back on
                """
            }
            
            contactTracingHubScreen.reminderSheetPauseContactTracingButton.tap()
            
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOff.exists) // contact tracing is now off
            
            runner.step("Confirmation alert") {
                """
                The user is presented a confirmation alert that he will be reminded in x hours
                """
            }
            
            XCTAssertTrue(contactTracingHubScreen.reminderAlertTitle.exists)
            contactTracingHubScreen.reminderAlertButton.tap()
            
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
        
        $runner.report(scenario: "Contact Tracing Hub", "Contact Tracing Off - No Notification Authorization") {
            """
            Users tap on the Manage contact tracing button in the Home screen,
            Users see the Contact Tracing Hub,
            Users toggle off contact tracing and do not see the option to set a reminder.
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.contactTracingHubButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on manage contact tracing button.
                """
            }
            
            app.scrollTo(element: homeScreen.contactTracingHubButton)
            homeScreen.contactTracingHubButton.tap()
            
            let contactTracingHubScreen = ContactTracingHubScreen(app: app)
            
            runner.step("Disable Contact tracing") {
                """
                The user is presented the Contact Tracing Hub screen.
                Users can disable contact tracing on the contact tracing hub
                """
            }
            
            // toggle contact tracing off
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOn.exists)
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOn.isHittable)
            contactTracingHubScreen.toggleOffSwitch()
            
            // check that there is no reminder sheet
            XCTAssertFalse(contactTracingHubScreen.reminderSheetTitle.exists)
            
            // since user notifications are off we just disable without showing the reminder sheet
            XCTAssertTrue(contactTracingHubScreen.exposureNotificationSwitchOff.exists)
            
            runner.step("Contact tracing off") {
                """
                User now sees that contact tracing is off
                """
            }
        }
    }
    
    func testShouldNotPauseContactTracing() throws {
        $runner.report(scenario: "Contact Tracing Hub", "When should I not pause contact tracing") {
            """
            Users tap on the Manage contact tracing button in the Home screen,
            Users see the Contact Tracing Hub,
            Users open 'When should I not pause contact tracing' advice and see that screen
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.contactTracingHubButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on manage contact tracing button.
                """
            }
            
            app.scrollTo(element: homeScreen.contactTracingHubButton)
            homeScreen.contactTracingHubButton.tap()
            
            let contactTracingHubScreen = ContactTracingHubScreen(app: app)
            
            runner.step("Open advice") {
                """
                The user is presented the Contact Tracing Hub screen.
                The user taps on 'You shouldn't pause contact tracing when' button.
                """
            }
            
            XCTAssertTrue(contactTracingHubScreen.shouldNotPauseButton.exists)
            app.scrollTo(element: contactTracingHubScreen.shouldNotPauseButton)
            XCTAssertTrue(contactTracingHubScreen.shouldNotPauseButton.isHittable)
            contactTracingHubScreen.shouldNotPauseButton.tap()
            
            let contactTracingAdviceScreen = ContactTracingAdviceScreen(app: app)
            
            runner.step("Advice screen is presented") {
                """
                User now sees 'When should I not pause contact tracing' advice screen.
                """
            }
            
            XCTAssertTrue(contactTracingAdviceScreen.heading.exists)
            XCTAssertTrue(contactTracingAdviceScreen.bulletItems.allExist)
            XCTAssertTrue(contactTracingAdviceScreen.footnote.exists)
        }
    }
    
    func testContactTracingDoesNotWorkWithoutBT() throws {
        $runner.initialState.bluetootOff = true
        try runner.run { app in
            
            let bluetoothOffWarningScren = BluetoothDisabledWarningScreen(app: app)
            bluetoothOffWarningScren.secondaryButton.tap()
            
            let homeScreen = HomeScreen(app: app)
            XCTAssert(homeScreen.contactTracingDoesNotWorkWithBTOffLabel.exists)
            
            app.scrollTo(element: homeScreen.contactTracingHubButton)
            homeScreen.contactTracingHubButton.tap()
            
            let bluetoothDisabledWarrningScreen = BluetoothDisabledWarningScreen(app: app)
            XCTAssert(bluetoothDisabledWarrningScreen.heading.exists)
        }
    }
}
