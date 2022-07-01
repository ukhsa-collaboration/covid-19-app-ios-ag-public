//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct WarnAndTestCheckSymptomsScreen {
    var app: XCUIApplication

    var titleLabel: XCUIElement {
        app.staticTexts[localized: .warn_and_test_check_symptoms_title]
    }

    var headingLabel: XCUIElement {
        app.staticTexts[localized: .warn_and_test_check_symptoms_heading]
    }

    var descriptionLabel: [XCUIElement] {
        app.staticTexts[localized: .test_check_symptoms_points]
    }

    var submitButton: XCUIElement {
        app.buttons[localized: .warn_and_test_check_symptoms_submit_button_title]
    }

    var cancelButton: XCUIElement {
        app.buttons[localized: .warn_and_test_check_symptoms_cancel_button_title]
    }
}
