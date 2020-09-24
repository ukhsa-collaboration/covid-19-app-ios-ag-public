//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct SimulatedShareRandomIdsScreen {
    typealias Text = Sandbox.Text.ExposureNotification
    
    var app: XCUIApplication
    
    var shareButton: XCUIElement {
        app.buttons[key: Text.diagnosisKeyAlertShare]
    }
    
    var dontShareButton: XCUIElement {
        app.buttons[key: Text.diagnosisKeyAlertDoNotShare]
    }
}
