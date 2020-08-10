//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct EndOfIsolationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_title]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_if_have_symptom_warning]
    }
    
    var explanation1Label: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_explanation_1]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .end_of_isolation_corona_back_to_home_button]
    }
    
    var furtherAdviceLink: XCUIElement {
        app.links[localized: .end_of_isolation_further_advice_link]
    }
    
}
