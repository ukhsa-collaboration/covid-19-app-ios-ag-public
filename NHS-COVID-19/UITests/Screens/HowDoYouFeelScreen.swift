//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct HowDoYouFeelScreen {
    let app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .how_you_feel_description]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .how_you_feel_header]
    }
    
    func yesRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.how_you_feel_yes_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }
    
    func noRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.how_you_feel_no_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .how_you_feel_continue_button]
    }
    
    var error: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.how_you_feel_error_title), content: localize(.how_you_feel_error_description))]
    }
        
}
