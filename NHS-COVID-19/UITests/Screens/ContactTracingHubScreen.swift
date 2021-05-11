//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct ContactTracingHubScreen {
    var app: XCUIApplication

    var exposureNotificationSwitchOn: XCUIElement {
        app.switches[localized: .contact_tracing_toggle_title_on]
    }
    
    var exposureNotificationSwitchOff: XCUIElement {
        app.switches[localized: .contact_tracing_toggle_title_off]
    }
    
    var pauseContactTracingButton: XCUIElement {
        app.buttons[localized: .exposure_notification_reminder_sheet_hours(hours: 8)]
    }
    
    var reminderAlertTitle: XCUIElement {
        app.staticTexts[localized: .exposure_notification_reminder_alert_title(hours: 8)]
    }
    
    var reminderAlertButton: XCUIElement {
        app.buttons[localized: .exposure_notification_reminder_alert_button]
    }
}
