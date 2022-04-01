//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseNoIsolationAdviceWalesScreen {
    var app: XCUIApplication
    
    var allElements: [XCUIElement] {
        [
            heading,
            meetingOutdoorsIcon,
            faceMaskListItem,
            swabTestListItem,
            washHandsListItem,
            contactsGuidanceLink,
            backToHomeButton,
        ]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_title_wales]
    }
    
    var meetingOutdoorsIcon: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_meeting_indoors_wales]
    }
    
    var faceMaskListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_mask_wales]
    }
    
    var swabTestListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_testing_hub_wales]
    }
    
    var washHandsListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_opt_out_advice_wash_hands_wales]
    }
    
    var contactsGuidanceLink: XCUIElement {
        app.links[localized: .risky_contact_opt_out_primary_button_title_wales]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .risky_contact_opt_out_secondary_button_title_wales]
    }
}
