//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct UnknownTestResultsScreen {
    var app: XCUIApplication

    var headingLabel: XCUIElement {
        app.staticTexts[localized: .unknown_test_result_screen_header]
    }

    var descriptionLabel: [XCUIElement] {
        app.staticTexts[localized: .unknown_test_result_screen_description]
    }

    var openStoreButton: XCUIElement {
        app.buttons[localized: .unknown_test_result_screen_button]
    }
}
