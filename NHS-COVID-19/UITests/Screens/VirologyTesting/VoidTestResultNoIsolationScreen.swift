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
        app.staticTexts[localized: .end_of_isolation_do_not_isolate_after_positive_test_warning]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .end_of_isolation_further_advice_visit]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }

    var primaryButton: XCUIElement {
        app.buttons[localized: .void_test_results_primary_button_title]
    }

    var cancelButton: XCUIElement {
        app.buttons[localized: .cancel]
    }
}
