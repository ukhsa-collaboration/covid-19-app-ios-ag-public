//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NoSymptomsScreen {
    var app: XCUIApplication
    
    var heading: XCUIElement {
        app.staticTexts[localized: .no_symptoms_heading]
    }
    
    var stillGetTestBodyElements: [XCUIElement] {
        localizeAndSplit(.no_symptoms_still_get_test_body).map { app.staticTexts[$0] }
    }
    
    var gettingTestedLink: XCUIElement {
        app.links[localized: .no_symptoms_getting_tested_link_label]
    }
    
    var developSymptomsBodyElements: [XCUIElement] {
        localizeAndSplit(.no_symptoms_develop_symptoms_body).map { app.staticTexts[$0] }
    }
    
    var nhs111Link: XCUIElement {
        app.links[localized: .no_symptoms_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .no_symptoms_return_home_button]
    }
    
    var returnHomeButtonAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsViewControllerScenario.returnHomeTapped]
    }
    
    var gettingTestedLinkAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsViewControllerScenario.gettingTestedLinkTapped]
    }
    
    var nhs111LinkAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsViewControllerScenario.nhs111LinkTapped]
    }
    
}
