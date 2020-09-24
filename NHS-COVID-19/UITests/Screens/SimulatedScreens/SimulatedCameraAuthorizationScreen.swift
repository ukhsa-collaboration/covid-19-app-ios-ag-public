//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct SimulatedCameraAuthorizationScreen {
    typealias Text = Sandbox.Text.CameraManager
    
    var app: XCUIApplication
    
    var allowButton: XCUIElement {
        app.buttons[key: Text.authorizationAlertAllow]
    }
    
    var dontAllowButton: XCUIElement {
        app.buttons[key: Text.authorizationAlertDoNotAllow]
    }
}
