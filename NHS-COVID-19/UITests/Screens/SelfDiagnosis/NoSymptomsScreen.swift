//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NoSymptomsScreen {
    var app: XCUIApplication
    
    var heading: XCUIElement {
        app.staticTexts[localized: .no_symptoms_heading]
    }
    
    var description1: XCUIElement {
        app.staticTexts[localized: .no_symptoms_body_1]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .no_symptoms_body_2]
    }
    
    var link: XCUIElement {
        app.links[localized: .no_symptoms_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .no_symptoms_return_home_button]
    }
    
    var returnHomeButtonAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsViewControllerScenario.returnHomeTapped]
    }
    
    var nhs111LinkAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsViewControllerScenario.nhs111LinkTapped]
    }
    
}
