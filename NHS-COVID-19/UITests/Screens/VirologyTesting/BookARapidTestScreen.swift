//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct BookARapidTestScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .virology_book_a_rapid_test_title]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .virology_book_a_rapid_test_heading]
    }

    var description: [XCUIElement] {
        app.staticTexts[localized: .virology_book_a_rapid_test_description]
    }

    var cancelButton: XCUIElement {
        app.buttons[localized: .virology_book_a_rapid_test_cancel_button]
    }

    var submitButton: XCUIElement {
        app.links[localized: .virology_book_a_rapid_test_submit_button]
    }
}
