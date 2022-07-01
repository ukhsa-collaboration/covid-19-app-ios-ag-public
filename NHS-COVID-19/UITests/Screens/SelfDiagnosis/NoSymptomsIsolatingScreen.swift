//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct NoSymptomsIsolatingScreen {
    var app: XCUIApplication

    var continueToIsolateLabel: XCUIElement {
        app.staticTexts[localize(.positive_test_please_isolate_accessibility_label(days: 14))]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .no_symptoms_isolating_info]
    }

    var explanationLabel: XCUIElement {
        app.staticTexts[localized: .no_symptoms_isolating_body]
    }

    var adviceLabel: XCUIElement {
        app.staticTexts[localized: .no_symptoms_isolating_advice]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .no_symptoms_isolating_services_link]
    }

    var returnHomeButton: XCUIElement {
        app.buttons[localized: .no_symptoms_isolating_return_home_button]
    }
}
