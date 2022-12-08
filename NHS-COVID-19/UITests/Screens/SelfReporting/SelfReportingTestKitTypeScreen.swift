//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingTestKitTypeScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_header]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_description]
    }

    var errorDescription: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_error_description]
    }

    func lfdRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_kit_type_radio_button_option_lfd)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func pcrRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_kit_type_radio_button_option_pcr)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }

    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(
            heading: localize(.error_box_title),
            content: localize(.self_report_test_kit_type_error_description)
        )]
    }

}
