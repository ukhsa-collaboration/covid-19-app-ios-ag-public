//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct PilotActivationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .authentication_code_title]
    }
    
    var description1: XCUIElement {
        app.staticTexts[localized: .authentication_code_description_1]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .authentication_code_description_2]
    }
    
    var textfieldHeading: XCUIElement {
        app.staticTexts[localized: .authentication_code_textfield_heading]
    }
    
    var textfieldExample: XCUIElement {
        app.staticTexts[localized: .authentication_code_textfield_example]
    }
    
    var infoHeading: XCUIElement {
        app.staticTexts[localized: .authentication_code_info_heading]
    }
    
    var infoDescription1: XCUIElement {
        app.staticTexts[localized: .authentication_code_info_description_1]
    }
    
    var infoExample: XCUIElement {
        app.staticTexts[localized: .authentication_code_info_example]
    }
    
    var infoDescription2: XCUIElement {
        app.staticTexts[localized: .authentication_code_info_description_2]
    }
    
    var button: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .authentication_code_button_title]
    }
    
    var errorDescription: XCUIElement {
        app.staticTexts[localized: .authentication_code_error_description]
    }
    
    var textfield: XCUIElement {
        app.textFields[localized: .authentication_code_textfield_label]
    }
}
