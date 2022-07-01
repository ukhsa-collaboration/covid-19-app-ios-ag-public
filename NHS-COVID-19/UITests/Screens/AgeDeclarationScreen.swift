//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct AgeDeclarationScreen {
    let app: XCUIApplication
    let birthThresholdDate: Date

    var title: XCUIElement {
        app.staticTexts[localized: .age_declaration_title]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .age_declaration_heading]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .age_declaration_description]
    }

    var question: XCUIElement {
        app.staticTexts[localized: .age_declaration_question(date: birthThresholdDate)]
    }

    func yesRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.age_declaration_yes_option_accessibility_text(date: birthThresholdDate))
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func noRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.age_declaration_no_option_accessibility_text(date: birthThresholdDate))
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .age_declaration_primary_button_title]
    }

    var error: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.age_declaration_error_title), content: localize(.age_declaration_error_description))]
    }
}
