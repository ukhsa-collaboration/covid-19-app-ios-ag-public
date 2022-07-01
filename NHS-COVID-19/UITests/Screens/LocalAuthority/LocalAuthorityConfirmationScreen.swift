//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct LocalAuthorityConfirmationScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .local_authority_confirmation_title]
    }

    func heading(postcode: String, localAuthority: String) -> XCUIElement {
        app.staticTexts[localized: .local_authority_confirmation_heading(postcode: postcode, localAuthority: localAuthority)]
    }

    var description: [XCUIElement] {
        app.staticTexts[localized: .local_authority_confirmation_description]
    }

    var button: XCUIElement {
        app.buttons[localized: .local_authority_confirmation_button]
    }
}
