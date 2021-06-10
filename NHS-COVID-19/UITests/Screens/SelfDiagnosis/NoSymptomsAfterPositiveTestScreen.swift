//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NoSymptomsAfterPositiveTestScreen {
    var app: XCUIApplication
    
    var heading: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_no_symptoms_after_positive_title]
    }
    
    var info: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_no_symptoms_after_positive_info]
    }
    
    var body: [XCUIElement] {
        app.staticTexts[localized: .self_diagnosis_no_symptoms_after_positive_body]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_no_symptoms_after_positive_advice]
    }
    
    var nhs111Link: XCUIElement {
        app.links[localized: .self_diagnosis_no_symptoms_after_positive_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .self_diagnosis_no_symptoms_after_positive_button_title]
    }
    
    var returnHomeButtonAlertTitle: XCUIElement {
        app.staticTexts[SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.returnHomeTapped]
    }
    
    var nhs111LinkAlertTitle: XCUIElement {
        app.staticTexts[SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.nhs111LinkTapped]
    }
    
}
