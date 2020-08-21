//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct EnterPostcodeScreen {
    var app: XCUIApplication
    
    var stepTitle: XCUIElement {
        app.staticTexts[localized: .postcode_entry_step_title]
    }
    
    var exampleLabel: XCUIElement {
        app.staticTexts[localized: .postcode_entry_example_label]
    }
    
    var informationTitle: XCUIElement {
        app.staticTexts[localized: .postcode_entry_information_title]
    }
    
    var informationDescription1: XCUIElement {
        app.staticTexts[localized: .postcode_entry_information_description_1]
    }
    
    var informationDescription2: XCUIElement {
        app.staticTexts[localized: .postcode_entry_information_description_2]
    }
    
    var postcodeTextField: XCUIElement {
        app.textFields[localized: .postcode_entry_textfield_label]
    }
    
    var errorTitle: XCUIElement {
        app.staticTexts[localized: .postcode_entry_error_title]
    }
    
    var errorDescription: XCUIElement {
        app.staticTexts[localized: .postcode_entry_error_description]
    }
    
    var continueButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .postcode_entry_continue_button_title]
    }
}
