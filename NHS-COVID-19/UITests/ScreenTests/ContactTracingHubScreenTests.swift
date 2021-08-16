//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactTracingHubScreenWhenUserNotificationsAuthorizedTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactTracingHubUserNotificationsAuthorizedScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            XCTAssertTrue(screen.exposureNotificationSwitchOn.exists)
            XCTAssertFalse(screen.exposureNotificationSwitchOff.exists)
            XCTAssertTrue(screen.noTrackingHeading.exists)
            XCTAssertTrue(screen.noTrackingDescription.exists)
            XCTAssertTrue(screen.privacyHeading.exists)
            XCTAssertTrue(screen.privacyDescription.exists)
            XCTAssertTrue(screen.batteryHeading.exists)
            XCTAssertTrue(screen.batteryDescription.exists)
            XCTAssertTrue(screen.findOutMoreSectionHeading.exists)
            XCTAssertTrue(screen.shouldNotPauseButton.exists)
            XCTAssertFalse(screen.reminderSheetTitle.exists)
            XCTAssertFalse(screen.reminderSheetPauseContactTracingButton.exists)
            XCTAssertFalse(screen.reminderAlertTitle.exists)
            XCTAssertFalse(screen.reminderAlertButton.exists)
        }
    }
    
    func testContactTracingSwitchOff() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            
            // toggle off contact tracing
            XCTAssert(screen.exposureNotificationSwitchOn.exists)
            XCTAssert(screen.exposureNotificationSwitchOn.isHittable)
            screen.exposureNotificationSwitchOn.tap()
            
            // toggle turns off before contract tracing is confirmed as off atm...
            XCTAssert(screen.exposureNotificationSwitchOff.exists)
            
            screen.reminderSheetPauseContactTracingButton.tap()
            XCTAssert(screen.exposureNotificationSwitchOff.exists) // contact tracing is now off
            
            XCTAssert(screen.reminderAlertTitle.exists)
            screen.reminderAlertButton.tap()
        }
    }
    
    func testTapOnShouldNotPauseContactTracingButton() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            app.scrollTo(element: screen.shouldNotPauseButton)
            screen.shouldNotPauseButton.tap()
            
            let alertTitle = app.staticTexts[ContactTracingHubAlertTitle.adviceWhenDoNotPauseCT]
            XCTAssert(alertTitle.displayed)
        }
    }
}

class ContactTracingHubScreenWhenUserNotificationsNotAuthorizedTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactTracingHubUserNotificationsNotAuthorizedScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            XCTAssertTrue(screen.exposureNotificationSwitchOn.exists)
            XCTAssertFalse(screen.exposureNotificationSwitchOff.exists)
            XCTAssertTrue(screen.noTrackingHeading.exists)
            XCTAssertTrue(screen.noTrackingDescription.exists)
            XCTAssertTrue(screen.privacyHeading.exists)
            XCTAssertTrue(screen.privacyDescription.exists)
            XCTAssertTrue(screen.batteryHeading.exists)
            XCTAssertTrue(screen.batteryDescription.exists)
            XCTAssertTrue(screen.findOutMoreSectionHeading.exists)
            XCTAssertTrue(screen.shouldNotPauseButton.exists)
            XCTAssertFalse(screen.reminderSheetTitle.exists)
            XCTAssertFalse(screen.reminderSheetPauseContactTracingButton.exists)
            XCTAssertFalse(screen.reminderAlertTitle.exists)
            XCTAssertFalse(screen.reminderAlertButton.exists)
        }
    }
    
    func testContactTracingSwitchOff() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            
            // toggle contact tracing off
            XCTAssert(screen.exposureNotificationSwitchOn.exists)
            XCTAssert(screen.exposureNotificationSwitchOn.isHittable)
            screen.exposureNotificationSwitchOn.tap()
            
            // check that there is no reminder sheet
            XCTAssertFalse(screen.reminderSheetTitle.exists)
            
            // since user notifications are off we just disable without showing the reminder sheet
            XCTAssert(screen.exposureNotificationSwitchOff.exists)
        }
    }
    
    func testTapOnShouldNotPauseContactTracingButton() throws {
        try runner.run { app in
            let screen = ContactTracingHubScreen(app: app)
            app.scrollTo(element: screen.shouldNotPauseButton)
            screen.shouldNotPauseButton.tap()
            
            let alertTitle = app.staticTexts[ContactTracingHubAlertTitle.adviceWhenDoNotPauseCT]
            XCTAssert(alertTitle.displayed)
        }
    }
}
