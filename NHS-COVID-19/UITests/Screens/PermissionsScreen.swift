//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct PermissionsScreen {
    var app: XCUIApplication
    
    var stepTitle: XCUIElement {
        app.staticTexts[localized: .permissions_onboarding_step_title]
    }
    
    var exposureNotificationHeading: XCUIElement {
        app.staticTexts[localized: .exposure_notification_permissions_onboarding_step_heading]
    }
    
    var notificationsHeading: XCUIElement {
        app.staticTexts[localized: .notification_permissions_onboarding_step_heading]
    }
    
    var exposureNotificationBody: XCUIElement {
        app.staticTexts[localized: .exposure_notification_permissions_onboarding_step_body]
    }
    
    var notificationsBody: XCUIElement {
        app.staticTexts[localized: .notification_permissions_onboarding_step_body]
    }
    
    var continueButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .permissions_continue_button_title]
    }
}
