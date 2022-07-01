//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PolicyUpdateScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .policy_update_title]
    }

    var description: [XCUIElement] {
        app.staticTexts[localized: .policy_update_description]
    }

    var link: XCUIElement {
        app.links[localized: .terms_of_use_label]
    }

    var button: XCUIElement {
        app.buttons[localized: .policy_update_button]
    }
}
