//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct ENDisabledScreen {
    var app: XCUIApplication
    
    var errorTitle: XCUIElement {
        app.staticTexts[localized: .exposure_notification_disabled_title]
    }
    
    var description1: XCUIElement {
        app.staticTexts[localized: .exposure_notification_disabled_description_1]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .exposure_notification_disabled_description_2]
    }
    
    var enableButton: XCUIElement {
        app.buttons[localized: .exposure_notification_disabled_action]
    }
    
}
