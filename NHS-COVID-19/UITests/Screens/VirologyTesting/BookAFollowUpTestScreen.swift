//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct BookAFollowUpTestScreen {
    var app: XCUIApplication

    var closeButton: XCUIElement {
        app.buttons[localized: .book_a_follow_up_test_close_button]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .book_a_follow_up_test_header]
    }

    var infoText: XCUIElement {
        app.staticTexts[localized: .book_a_follow_up_test_info]
    }

    var bodyTextElements: [XCUIElement] {
        localizeAndSplit(.book_a_follow_up_test_body)
            .map { text in
                let predicate = NSPredicate(format: "label == '\(text)'")
                return app.staticTexts.containing(predicate).element
            }
    }

    var adviceLinkLabel: XCUIElement {
        app.staticTexts[localized: .book_a_follow_up_test_advice_link_title]
    }

    var adviceLinkButton: XCUIElement {
        app.links[localized: .book_a_follow_up_test_advice_link]
    }

    var primaryButton: XCUIElement {
        app.buttons[localized: .book_a_follow_up_test_button]
    }
}
