//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct VoidTestResultNoIsolationScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .void_test_result_no_isolation_title]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .void_test_result_no_isolation_warning]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .void_test_result_no_isolation_further_advice_visit]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .nhs111_online_link_title]
    }

    var primaryButton: XCUIElement {
        app.buttons[localized: .void_test_results_primary_button_title]
    }

    var cancelButton: XCUIElement {
        app.buttons[localized: .cancel]
    }
}
