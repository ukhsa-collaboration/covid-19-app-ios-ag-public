//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct AuthorizationDeniedScreen {
    var app: XCUIApplication

    var errorTitle: XCUIElement {
        app.staticTexts[localized: .authorization_denied_title]
    }

    var description: [XCUIElement] {
        app.staticTexts[localized: .authorization_denied_description]
    }

    var settingsButton: XCUIElement {
        app.buttons[localized: .authorization_denied_action]
    }

}
