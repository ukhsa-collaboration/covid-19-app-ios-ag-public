//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfIsolationHubScreen {
    let app: XCUIApplication

    var bookFreeTestButton: XCUIElement {
        app.buttons.element(containing: localize(.self_isolation_hub_book_a_test_title))
    }

    var financialSupportButton: XCUIElement {
        app.buttons.element(containing: localize(.self_isolation_hub_financial_support_title))
    }

    var isolationNoteButton: XCUIElement {
        app.links.element(containing: localize(.self_isolation_hub_get_isolation_note_title))
    }

    var howToSelfIsolateAccordionTitleButton: XCUIElement {
        app.buttons[localized: .self_isolation_hub_accordion_how_to_title]
    }

    var readLatestGovenrnmentGuidanceLink: XCUIElement {
        app.links[localized: .self_isolation_hub_read_gov_guidance_link_title]
    }

    var findYourLocalAuthorityLink: XCUIElement {
        app.links[localized: .self_isolation_hub_find_your_la_link_title]
    }

    var practicalSupportAccordionTitleButton: XCUIElement {
        app.buttons[localized: .self_isolation_hub_accordion_practical_support_title]
    }
}
