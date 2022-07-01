//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct SymptomsAfterPositiveTestScreen {
    var app: XCUIApplication

    var pleaseIsolateLabel: XCUIElement {
        app.staticTexts[localize(.positive_test_start_to_isolate_accessibility_label(days: 7))]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_symptoms_after_positive_info]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .self_diagnosis_symtpoms_after_positive_body]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .self_diagnosis_symptoms_after_positive_button_title]
    }

    var furtherAdviceLink: XCUIElement {
        app.links[localized: .self_diagnosis_symptoms_after_positive_link]
    }

}
