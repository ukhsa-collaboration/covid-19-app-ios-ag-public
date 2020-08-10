//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct SymptomsReviewScreen {
    var app: XCUIApplication
    
    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.symptom_list_error_heading), content: localize(.symptom_review_error_description))]
    }
    
    var stepsLabel: XCUIElement {
        app.staticTexts[localized: .step_accessibility_label(index: 2, count: 2)]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .symptom_review_heading]
    }
    
    var confirmHeading: XCUIElement {
        app.staticTexts[localized: .symptom_review_confirm_heading]
    }
    
    var denyHeading: XCUIElement {
        app.staticTexts[localized: .symptom_review_deny_heading]
    }
    
    var dateHeading: XCUIElement {
        app.staticTexts[localized: .symptom_review_date_heading]
    }
    
    var noDate: XCUIElement {
        app.buttons[localized: .symptom_review_no_date_accessability_label_not_checked]
    }
    
    var confirmButton: XCUIElement {
        app.buttons[localized: .symptom_review_button_submit]
    }
    
    var changeButton: XCUIElement {
        app.buttons[localized: .symptom_review_button_accessibility_label(symptom: SymptomsReviewViewControllerScenario.confirmedForCough)].firstMatch
    }
    
    var changeAlertText: XCUIElement {
        app.staticTexts["1"]
    }
    
    var confirmAlertText: XCUIElement {
        app.staticTexts[SymptomsReviewViewControllerScenario.confirmTapped]
    }
}
