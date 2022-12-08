//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingTestTypeScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .self_report_test_type_title]
    }

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_test_type_header]
    }

    var errorDescription: XCUIElement {
        app.staticTexts[localized: .self_report_test_type_error_description]
    }

    func positiveRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_type_radio_button_option_positive)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func negativeRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_type_radio_button_option_negative)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func voidRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_type_radio_button_option_void)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }

    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(
            heading: localize(.error_box_title),
            content: localize(.self_report_test_type_error_description)
        )]
    }

}
