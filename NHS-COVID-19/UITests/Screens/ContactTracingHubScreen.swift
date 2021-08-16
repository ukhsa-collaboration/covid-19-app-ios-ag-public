//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct ContactTracingHubScreen {
    var app: XCUIApplication
    
    var exposureNotificationSwitchOn: XCUIElement {
        app.switches[localized: .contact_tracing_toggle_title_on]
    }
    
    var exposureNotificationSwitchOff: XCUIElement {
        app.switches[localized: .contact_tracing_toggle_title_off]
    }
    
    func toggleOnSwitch() {
        toggleSwitch(.contact_tracing_toggle_title_off)
    }
    
    func toggleOffSwitch() {
        toggleSwitch(.contact_tracing_toggle_title_on)
    }
    
    /// Workaround because `tap()` method doesn't work properly with `SwiftUI.Toggle`.
    /// It taps on a whole toggle view (including text) instead of switch element.
    /// This method finds switch and taps on it.
    private func toggleSwitch(_ key: StringLocalizableKey) {
        let switchElement: XCUIElement = app.switches[localized: key]
        
        let horizontalOffset: CGFloat = 5
        let switchPosition: CGPoint
        
        // find switch position
        if currentLanguageDirection() == .rightToLeft {
            switchPosition = CGPoint(x: switchElement.frame.origin.x + horizontalOffset, y: switchElement.frame.height / 2)
        } else {
            switchPosition = CGPoint(x: switchElement.frame.width - horizontalOffset, y: switchElement.frame.height / 2)
        }
        
        let switchCooridnate = switchElement
            .coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: switchPosition.x, dy: switchPosition.y))
        
        switchCooridnate.tap()
    }
    
    var noTrackingHeading: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_no_tracking_heading]
    }
    
    var noTrackingDescription: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_no_tracking_description]
    }
    
    var privacyHeading: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_privacy_heading]
    }
    
    var privacyDescription: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_privacy_description]
    }
    
    var batteryHeading: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_battery_heading]
    }
    
    var batteryDescription: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_battery_description]
    }
    
    var findOutMoreSectionHeading: XCUIElement {
        app.staticTexts[localized: .contact_tracing_hub_find_out_more]
    }
    
    var shouldNotPauseButton: XCUIElement {
        app.buttons[localized: .contact_tracing_hub_should_not_pause]
    }
    
    var reminderSheetTitle: XCUIElement {
        app.staticTexts[localized: .exposure_notification_reminder_sheet_title]
    }
    
    var reminderSheetPauseContactTracingButton: XCUIElement {
        app.buttons[localized: .exposure_notification_reminder_sheet_hours(hours: 8)]
    }
    
    var reminderAlertTitle: XCUIElement {
        app.staticTexts[localized: .exposure_notification_reminder_alert_title(hours: 8)]
    }
    
    var reminderAlertButton: XCUIElement {
        app.buttons[localized: .exposure_notification_reminder_alert_button]
    }
}
