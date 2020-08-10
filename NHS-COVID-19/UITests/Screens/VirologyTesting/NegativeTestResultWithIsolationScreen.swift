//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NegativeTestResultWithIsolationScreen {
    var app: XCUIApplication
    
    var continueToIsolateLabel: XCUIElement {
        app.staticTexts[localize(.positive_test_please_isolate_accessibility_label(days: 12))]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .negative_test_result_with_isolation_info]
    }
    
    var explanationLabel: XCUIElement {
        app.staticTexts[localized: .negative_test_result_with_isolation_explanation]
    }
    
    var adviceLabel: XCUIElement {
        app.staticTexts[localized: .negative_test_result_with_isolation_advice]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .negative_test_result_with_isolation_service_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .negative_test_result_with_isolation_back_to_home]
    }
}
