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
    
    var description: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_warn_and_book_a_test_description]
    }
    
    var bookATestButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_book_a_test_button_title]
    }
    
    var bookATestLaterButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_will_book_a_test_later_button_title]
    }
}
