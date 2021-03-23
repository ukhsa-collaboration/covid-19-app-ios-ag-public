//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct TestSymptomsReviewScreen {
    var app: XCUIApplication
    
    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.symptom_list_error_heading), content: localize(.symptom_review_error_description))]
    }
    
    var noDate: XCUIElement {
        app.buttons[localized: .symptom_review_no_date_accessability_label_not_checked]
    }
    
    var headingLabel: XCUIElement {
        app.staticTexts[localized: .test_symptoms_date_heading]
    }
    
    var descriptionLabel: [XCUIElement] {
        app.staticTexts[localized: .test_check_symptoms_points]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .test_symptoms_date_continue]
    }
    
    var doneButton: XCUIElement {
        app.buttons[localized: .done]
    }
    
    var confirmAlertText: XCUIElement {
        app.staticTexts[TestSymptomsReviewScreenScenario.confirmTapped]
    }
    
    var dateTextField: XCUIElement {
        app.staticTexts[localized: .symptom_review_date_placeholder]
    }
    
    var dateButton: XCUIElement {
        app.buttons[localized: .symptom_review_date_placeholder]
    }
    
}
