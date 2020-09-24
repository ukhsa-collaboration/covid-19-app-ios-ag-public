//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct CameraFailureScreen {
    
    var app: XCUIApplication
    
    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_camera_failure_title]
    }
    
    var screenDescription: XCUIElement {
        app.staticTexts[localized: .checkin_camera_failure_description]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .checkin_camera_failure_button_title]
    }
}
