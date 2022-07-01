//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct TestingHubScreen {
    let app: XCUIApplication

    var bookFreeTestButton: XCUIElement {
        app.buttons.element(containing: localize(.testing_hub_row_book_lab_test_title))
    }

    var orderTestKitLinkButton: XCUIElement {
        app.links.element(containing: localize(.testing_hub_row_order_free_test_title))
    }

    var enterTestResultButton: XCUIElement {
        app.buttons.element(containing: localize(.testing_hub_row_enter_test_result_title))
    }

    var findOutMoreAboutTestingAccordionTitleButton: XCUIElement {
        app.buttons[localized: .testing_hub_accordion_find_out_about_testing_title]
    }

    var findOutMoreAboutTestingLink: XCUIElement {
        app.links[localized: .testing_hub_accordion_find_out_about_testing_link_title]
    }
}
