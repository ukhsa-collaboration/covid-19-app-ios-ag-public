//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveTestResultContinueIsolationScreen {
    var app: XCUIApplication
    
    func daysIsolateLabel(daysRemaining: Int) -> XCUIElement {
        app.staticTexts[localized: .positive_test_please_isolate_accessibility_label(days: daysRemaining)]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .positive_test_result_info]
    }
    
    var explanationLabel: XCUIElement {
        #warning("This assertion is incorrect.")
        // If explaination copy is multiple paragraphs, it’ll be broken down into multiple labels to improve accessibility.
        return app.staticTexts[localized: .positive_test_result_explanation]
    }
    
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .positive_test_results_continue]
    }
}
