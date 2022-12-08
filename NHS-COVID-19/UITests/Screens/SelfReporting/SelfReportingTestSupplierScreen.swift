//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingTestSupplierScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_header]
    }

    var bulletedListHeader: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_bulleted_list_header]
    }

    var bulletedList: [XCUIElement] {
        app.staticTexts[localized: .self_report_test_supplier_bulleted_list]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_description]
    }

    var errorDescription: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_error_description]
    }

    func yesRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_supplier_first_radio_button_label)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func noRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.self_report_test_supplier_second_radio_button_label)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }

    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(
            heading: localize(.error_box_title),
            content: localize(.self_report_test_supplier_error_description)
        )]
    }

}
