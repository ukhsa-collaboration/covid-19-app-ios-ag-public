//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveTestResultNoIsolationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_positive_text_no_isolation_title]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_if_have_symptom_warning]
    }
    
    var explanationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_further_advice_visit]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .positive_test_results_continue]
    }
}
