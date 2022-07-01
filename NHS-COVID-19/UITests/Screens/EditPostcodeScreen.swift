//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct EditPostcodeScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .postcode_entry_step_title]
    }

    var postcodeExample: XCUIElement {
        app.staticTexts[localized: .postcode_entry_example_label]
    }

    var errorTitle: XCUIElement {
        app.staticTexts[localized: .postcode_entry_error_title]
    }

    var postcodeTextField: XCUIElement {
        app.textFields[localized: .postcode_entry_textfield_label]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .edit_postcode_continue_button]
    }

    var saveButton: XCUIElement {
        app.buttons[localized: .edit_postcode_save_button]
    }
}
