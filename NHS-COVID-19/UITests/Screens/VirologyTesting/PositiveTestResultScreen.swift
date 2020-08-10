//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveTestResultScreen {
    var app: XCUIApplication
    
    var pleaseIsolateLabel: XCUIElement {
        app.staticTexts[localize(.positive_test_please_isolate_accessibility_label(days: 7))]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .positive_test_result_info]
    }
    
    var explanationLabel: XCUIElement {
        app.staticTexts[localized: .positive_test_result_explanation]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .positive_test_results_continue]
    }
}
