//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseNoIsolationAdviceScreen {
    var app: XCUIApplication

    var allElements: [XCUIElement] {
        [
            heading,
            meetingOutdoorsIcon,
            faceMaskListItem,
            washHandsListItem,
            contactsGuidanceLink,
            backToHomeButton,
        ]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_title]
    }

    var meetingOutdoorsIcon: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_meeting_indoors]
    }

    var faceMaskListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_mask]
    }

    var washHandsListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_wash_hands]
    }

    var contactsGuidanceLink: XCUIElement {
        app.links[localized: .risky_contact_opt_out_primary_button_title]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .risky_contact_opt_out_secondary_button_title]
    }
}
