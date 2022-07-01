//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct ThankYouScreen {
    var app: XCUIApplication

    var thankYouHeadingText: XCUIElement {
        app.staticTexts[localized: .link_test_result_thank_you_title]
    }

    var headingText: XCUIElement {
        app.staticTexts[localized: .link_test_result_thank_you_title]
    }

    var backHomeButtonText: XCUIElement {
        app.buttons[localized: .link_test_result_thank_you_back_home_button]
    }

    var continueButtonText: XCUIElement {
        app.buttons[localized: .link_test_result_thank_you_continue_to_book_a_test_button]
    }
}
