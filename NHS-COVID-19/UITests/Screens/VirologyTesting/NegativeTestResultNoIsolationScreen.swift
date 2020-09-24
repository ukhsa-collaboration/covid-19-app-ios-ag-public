//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NegativeTestResultNoIsolationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .negative_test_result_no_isolation_title]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .negative_test_result_no_isolation_description]
    }
    
    var warning: XCUIElement {
        app.staticTexts[localized: .negative_test_result_no_isolation_warning]
    }
    
    var linkHint: XCUIElement {
        app.staticTexts[localized: .negative_test_result_no_isolation_link_hint]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .negative_test_result_no_isolation_link_label]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .negative_test_result_no_isolation_button_label]
    }
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultNoIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultNoIsolationScreenScenario.returnHomeTapped]
    }
}
