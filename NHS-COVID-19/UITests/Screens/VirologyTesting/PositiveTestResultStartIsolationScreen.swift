//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveTestResultStartIsolationScreen {
    var app: XCUIApplication

    func daysIsolateLabel(daysRemaining: Int) -> XCUIElement {
        app.staticTexts[localized: .try_to_stay_at_home_for_wales_header(days: daysRemaining)]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .infobox_after_positive_test_wales]
    }

    var explanationLabels: [XCUIElement] {
        return app.staticTexts[localized: .positive_test_result_start_to_isolate_explaination]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }

    var exposureFAQLink: XCUIElement {
        app.links[localized: .exposure_faqs_link_button_title]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .positive_test_results_continue]
    }
}
