//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct GuidanceForSymptomaticCasesEnglandScreen {
    var app: XCUIApplication
    
    var allElements: [XCUIElement] {
        [
            heading,
            faceMaskListItem,
            socialDistancingListItem,
            meetingInddorsListItem,
            washHandsListItem,
            commonQuestionsLink,
            furtherAdviceLabel,
            nhsOnlineLink,
            backToHomeButton,
        ]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_title_england]
    }
    
    var faceMaskListItem: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_mask_england]
    }
    
    var socialDistancingListItem: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_testing_hub_england]
    }
    
    var meetingInddorsListItem: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_meeting_indoors_england]
    }
    
    var washHandsListItem: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_wash_hands_england]
    }
    
    var commonQuestionsLink: XCUIElement {
        app.links[localized: .symptomatic_contact_guidance_common_questions_link_england]
    }
    
    var furtherAdviceLabel: XCUIElement {
        app.staticTexts[localized: .symptomatic_contact_guidance_further_advice_england]
    }
    
    var nhsOnlineLink: XCUIElement {
        app.links[localized: .symptomatic_contact_guidance_nhs_online_link_england]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .symptomatic_contact_primary_button_title_england]
    }
}
