//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NegativeTestResultScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_title]
    }
    
    var endOfIsolationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_finished_description]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_negative_test_result]
    }
    
    var explanationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_explanation_negative_test_result]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .end_of_isolation_corona_back_to_home_button]
    }
}
