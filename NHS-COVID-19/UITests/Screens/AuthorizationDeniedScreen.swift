//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct AuthorizationDeniedScreen {
    var app: XCUIApplication
    
    var errorTitle: XCUIElement {
        app.staticTexts[localized: .authorization_denied_title]
    }
    
    var description1: XCUIElement {
        app.staticTexts[localized: .authorization_denied_description_1]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .authorization_denied_description_2]
    }
    
    var description3: XCUIElement {
        app.staticTexts[localized: .authorization_denied_description_3]
    }
    
    var settingsButton: XCUIElement {
        app.buttons[localized: .authorization_denied_action]
    }
    
}
