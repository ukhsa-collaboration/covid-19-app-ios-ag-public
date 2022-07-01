//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct SimulatedENAuthorizationScreen {
    typealias Text = Sandbox.Text.ExposureNotification

    var app: XCUIApplication

    var allowButton: XCUIElement {
        app.buttons[key: Text.authorizationAlertAllow]
    }
}
