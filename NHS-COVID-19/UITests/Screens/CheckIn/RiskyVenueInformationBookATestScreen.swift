//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct RiskyVenueInformationBookATestScreen {

    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_warn_and_book_a_test_title]
    }

    var info: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_warn_and_book_a_test_info]
    }

    var bulletedList: [XCUIElement] {
        app.staticTexts[localized: .checkin_risky_venue_information_warn_and_book_a_test_bulleted_list]
    }

    var additionalInfo: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_warn_and_book_a_test_additional_info]
    }

    var bookATestButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_book_a_test_button_title]
    }

    var bookATestLaterButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_will_book_a_test_later_button_title]
    }

    var closeButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_warn_and_book_a_test_close_button]
    }
}
