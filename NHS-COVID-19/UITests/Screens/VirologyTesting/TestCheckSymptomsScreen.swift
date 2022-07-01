//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct TestCheckSymptomsScreen {
    var app: XCUIApplication

    var titleLabel: XCUIElement {
        app.staticTexts[localized: .link_test_result_symptom_information_title]
    }

    var headingLabel: XCUIElement {
        app.staticTexts[localized: .test_check_symptoms_heading]
    }

    var descriptionLabel: [XCUIElement] {
        app.staticTexts[localized: .test_check_symptoms_points]
    }

    var yesButton: XCUIElement {
        app.buttons[localized: .test_check_symptoms_yes]
    }

    var noButton: XCUIElement {
        app.buttons[localized: .test_check_symptoms_no]
    }
}
