//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct BluetoothDisabledScreen {
    var app: XCUIApplication

    var errorTitle: XCUIElement {
        app.staticTexts[localized: .bluetooth_disabled_title]
    }

    var description: [XCUIElement] {
        app.staticTexts[localized: .bluetooth_disabled_description]
    }
}
