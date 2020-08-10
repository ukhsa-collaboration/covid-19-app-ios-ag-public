//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct SimulatedUserNotificationAuthorizationScreen {
    typealias Text = Sandbox.Text.UserNotification
    
    var app: XCUIApplication
    
    var allowButton: XCUIElement {
        app.buttons[key: Text.authorizationAlertAllow]
    }
}
