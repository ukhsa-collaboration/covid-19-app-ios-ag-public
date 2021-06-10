//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct DiscardedSymptomsAfterPositiveTestScreen {
    var app: XCUIApplication
    
    var heading: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_symptoms_after_positive_discarded_title]
    }
    
    var info: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_symptoms_after_positive_discarded_info]
    }
    
    var body: [XCUIElement] {
        app.staticTexts[localized: .self_diagnosis_symptoms_after_positive_discarded_body]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .self_diagnosis_symptoms_after_positive_discarded_advice]
    }
    
    var nhs111Link: XCUIElement {
        app.links[localized: .self_diagnosis_symptoms_after_positive_discarded_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .self_diagnosis_symptoms_after_positive_discarded_button_title]
    }
    
    var returnHomeButtonAlertTitle: XCUIElement {
        app.staticTexts[SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.returnHomeTapped]
    }
    
    var nhs111LinkAlertTitle: XCUIElement {
        app.staticTexts[SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.nhs111LinkTapped]
    }
    
}
