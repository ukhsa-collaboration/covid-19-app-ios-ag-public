//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct ContactTracingBluetoothScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .onboarding_permissions_bluetooth_title]
    }

    var description1: XCUIElement {
        app.staticTexts[localized: .onboarding_permissions_bluetooth_description]
    }

    var description2: XCUIElement {
        app.staticTexts[localized: .onboarding_permissions_bluetooth_description2]
    }

    var bullets: [XCUIElement] {
        app.staticTexts[localized: .onboarding_permissions_bluetooth_checklist]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .onboarding_permissions_bluetooth_continue_button_title]
    }

}
