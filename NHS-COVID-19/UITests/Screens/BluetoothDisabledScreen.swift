//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct BluetoothDisabledScreen {
    var app: XCUIApplication
    
    var errorTitle: XCUIElement {
        app.staticTexts[localized: .bluetooth_disabled_title]
    }
    
    var description1: XCUIElement {
        app.staticTexts[localized: .bluetooth_disabled_description_1]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .bluetooth_disabled_description_2]
    }
    
    var description3: XCUIElement {
        app.staticTexts[localized: .bluetooth_disabled_description_3]
    }
}
