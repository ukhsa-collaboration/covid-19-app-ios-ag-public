//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct HomeScreen {
    var app: XCUIApplication
    
    func riskLevelBanner(for postcode: String, title: String) -> XCUIElement {
        app.buttons[verbatim: title.replacingOccurrences(of: "[postcode]", with: postcode)]
    }
    
    var diagnoisButton: XCUIElement {
        app.buttons[localized: .home_diagnosis_button_title]
    }
    
    var adviceButton: XCUIElement {
        app.links[localized: .home_default_advice_button_title]
    }
    
    var testingInformationButton: XCUIElement {
        app.buttons[localized: .home_testing_information_button_title]
    }
    
    var financeButton: XCUIElement {
        app.buttons[localized: .home_financial_support_button_title]
    }
    
    var checkInButton: XCUIElement {
        app.buttons[localized: .home_checkin_button_title]
    }
    
    var aboutButton: XCUIElement {
        app.buttons[localized: .home_about_the_app_button_title]
    }
    
    var exposureNotificationSwitch: XCUIElement {
        app.switches[localized: .home_toggle_exposure_notification_title]
    }
    
    func isolatingIndicator(date: Date, days: Int) -> XCUIElement {
        app.staticTexts[localized: .isolation_indicator_accessiblity_label(date: date, days: days)]
    }
    
    var notIsolatingIndicator: XCUIElement {
        app.staticTexts[localized: .risk_level_indicator_contact_tracing_active]
    }
    
    var disabledContactTracing: XCUIElement {
        app.staticTexts[localized: .risk_level_indicator_contact_tracing_not_active]
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
