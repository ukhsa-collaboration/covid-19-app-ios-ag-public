//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct BluetoothDisabledWarningScreen {
    var app: XCUIApplication
    
    var heading: XCUIElement {
        app.staticTexts[localized: .launcher_permissions_bluetooth_title]
    }
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .launcher_permissions_bluetooth_hint]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .launcher_permissions_bluetooth_description]
    }
    
    var primaryButton: XCUIElement {
        app.buttons[localized: .launcher_permissions_bluetooth_button]
    }
    
    var secondaryButton: XCUIElement {
        app.buttons[localized: .launcher_permissions_bluetooth_secondary_button]
    }
}
