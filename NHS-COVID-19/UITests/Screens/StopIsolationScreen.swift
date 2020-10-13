//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct StopIsolationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .stop_isolation_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .stop_isolation_heading]
    }
    
    var body: [XCUIElement] {
        app.staticTexts[localized: .stop_isolation_body]
    }
    
    var primaryButton: XCUIElement {
        app.buttons[localized: .stop_isolation_countdown_button]
    }
}
