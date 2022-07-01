//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct LinkTestResultScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .link_test_result_title]
    }

    var header: XCUIElement {
        app.staticTexts[localized: .link_test_result_header]
    }

    var yourTestResultShould: XCUIElement {
        app.staticTexts[localized: .link_test_result_your_test_result_code_should]
    }

    var subheading: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_heading]
    }

    var exampleLabel: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_example]
    }

    var error: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_invalid_error]
    }

    var scenarioError: XCUIElement {
        app.staticTexts[LinkTestResultScreenScenario.invalidCodeError]
    }

    var testCodeTextField: XCUIElement {
        app.textFields[localized: .link_test_result_enter_code_textfield_label]
    }

    var continueButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .link_test_result_button_title]
    }

    var cancelButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .cancel]
    }
}
