//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct VoidTestResultWithIsolationScreen {
    var app: XCUIApplication

    func daysIsolateLabel(daysRemaining: Int) -> XCUIElement {
        app.staticTexts[localized: .positive_test_please_isolate_accessibility_label(days: daysRemaining)]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .void_test_result_info]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .void_test_result_explanation]
    }

    var nhsGuidanceLink: XCUIElement {
        app.links[localized: .void_test_result_with_isolation_nhs_guidance_link]
    }

    var primaryButton: XCUIElement {
        app.buttons[localized: .void_test_results_primary_button_title]
    }

    var cancelButton: XCUIElement {
        app.buttons[localized: .cancel]
    }
}
