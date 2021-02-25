//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct DailyContactTestingConfirmationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_heading]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_description]
    }
    
    var bulletedListContinueHeading: XCUIElement {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_bulleted_list_continue_heading]
    }
    
    var bulletedListContinue: [XCUIElement] {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_bulleted_list_continue]
    }
    
    var bulletedListNoLongerHeading: XCUIElement {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_bulleted_list_no_longer_heading]
    }
    
    var bulletedListNoLonger: [XCUIElement] {
        app.staticTexts[localized: .daily_contact_testing_confirmation_screen_bulleted_list_no_longer]
    }
    
    var confirmButton: XCUIElement {
        app.buttons[localized: .daily_contact_testing_confirmation_screen_confirm_button_title]
    }
    
    var confirmAlert: XCUIElement {
        XCTAssertTrue(app.alerts.staticTexts[localized: .daily_contact_testing_confirmation_screen_alert_title].exists)
        XCTAssertTrue(app.alerts.staticTexts[localized: .daily_contact_testing_confirmation_screen_alert_body_description].exists)
        return app.alerts.buttons[localized: .daily_contact_testing_confirmation_screen_alert_confirm_button_title]
    }
}
