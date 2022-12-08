//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingSymptomsDateScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_date_header]
    }

    var bulletedList: [XCUIElement] {
        app.staticTexts[localized: .self_report_symptoms_date_bulleted_list]
    }

    var errorDescription: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_date_error_description]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }

    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(
            heading: localize(.error_box_title),
            content: localize(.self_report_symptoms_date_error_description)
        )]
    }

    var doNotRememberNotChecked: XCUIElement {
        app.buttons[localized: .self_report_symptoms_date_no_date_accessability_label_not_checked]
    }

    var doNotRememberChecked: XCUIElement {
        app.buttons[localized: .self_report_symptoms_date_no_date_accessability_label_checked]
    }

    var doneButton: XCUIElement {
        app.buttons[localized: .done]
    }

    var dateTextField: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_date_placeholder]
    }

    var dateButton: XCUIElement {
        app.buttons[localized: .self_report_symptoms_date_placeholder]
    }
}
