//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct EndOfIsolationScreen {
    var app: XCUIApplication

    // MARK: - Index and Contact Cases (England and Wales)
    var title: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_title]
    }

    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_if_have_symptom_warning]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }

    var returnHomeButton: XCUIElement {
        app.buttons[localized: .end_of_isolation_corona_back_to_home_button]
    }

}
