//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct CameraAccessDeniedScreen {
    
    var app: XCUIApplication
    
    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_camera_permission_denial_title]
    }
    
    var screenDescription: XCUIElement {
        app.staticTexts[localized: .checkin_camera_permission_denial_explanation]
    }
    
}
