//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveSymptomsNoIsolationScreen {
    var app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localize(.positive_symptoms_no_isolation_heading)]
    }

    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .positive_symptoms_no_isolation_explanation]
    }

    var furtherAdviceLabel: XCUIElement {
        app.staticTexts[localized: .positive_symptoms_no_isolation_advice]
    }

    var nhs111OnlineLink: XCUIElement {
        app.links[localized: .nhs_111_online_service]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .positive_symptoms_no_isolation_home_button]
    }
}
