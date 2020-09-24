//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct SymptomsListScreen {
    var app: XCUIApplication
    
    var errorBox: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.symptom_list_error_heading), content: localize(.symptom_list_error_description))]
    }
    
    var stepsLabel: XCUIElement {
        app.staticTexts[localized: .step_accessibility_label(index: 1, count: 2)]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .symptom_list_heading]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .symptom_list_description]
    }
    
    func symptomCard(value: String, heading: String, content: String) -> XCUIElement {
        app.buttons[localized: .symptom_card_checkbox_accessibility_label(value: value, heading: heading, content: content)]
    }
    
    var reportButton: XCUIElement {
        app.buttons[localized: .symptom_list_primary_action]
    }
    
    var reportAlertTitle: XCUIElement {
        app.staticTexts[SymptomsListViewControllerScenario.reportTapped]
    }
    
    var noSymptomsButton: XCUIElement {
        app.buttons[localized: .symptom_list_secondary_action]
    }
    
    var noSymptomsAlertTitle: XCUIElement {
        app.staticTexts[SymptomsListViewControllerScenario.noSymptomsTapped]
    }
    
    var discardAlertTitle: XCUIElement {
        app.staticTexts[localized: .symptom_list_discard_alert_title]
    }
    
    var discardAlertBody: XCUIElement {
        app.staticTexts[localized: .symptom_list_discard_alert_body]
    }
    
    var discardAlertCancel: XCUIElement {
        app.alerts.buttons[localized: .symptom_list_discard_alert_cancel]
    }
    
    var discardAlertDiscard: XCUIElement {
        app.buttons[localized: .symptom_list_discard_alert_discard]
    }
}
