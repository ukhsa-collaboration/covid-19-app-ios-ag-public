//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveTestResultContinueIsolationAfterConfirmedScreen {
    var app: XCUIApplication

    func daysIsolateLabel(daysRemaining: Int) -> XCUIElement {
        app.staticTexts[localized: .positive_test_please_isolate_accessibility_label(days: daysRemaining)]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .positive_test_result_already_confirmed_positive_info]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .positive_test_result_already_confirmed_positive_explanation]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }

    var exposureFAQLink: XCUIElement {
        app.links[localized: .exposure_faqs_link_button_title]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .positive_test_result_already_confirmed_positive_continue]
    }
}
