//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseNoIsolationMedicallyExemptScreen {
    var app: XCUIApplication

    var allElements: [XCUIElement] {
        [
            heading,
            infoBox,
            socialDistancingListItem,
            swabTestListItem,
            faceMaskListItem,
            workFromHomeListItem,
            readGuidanceLinkButton,
            backToHomeButton,
        ]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt]
    }

    var infoBox: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_info]
    }

    var socialDistancingListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_social_distancing_england]
    }

    var swabTestListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_get_tested_before_meeting_vulnerable_people_england]
    }

    var faceMaskListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_wear_a_mask_england]
    }

    var workFromHomeListItem: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_work_from_home_england]
    }

    var commonQuestionsLink: XCUIElement {
        app.links[localized: .risky_contact_isolation_advice_medically_exempt_common_questions_link_title]
    }

    var guidanceLink: XCUIElement {
        app.links[localized: .risky_contact_isolation_advice_medically_exempt_nhs_guidance_link_title]
    }

    var readGuidanceLinkButton: XCUIElement {
        app.links[localized: .risky_contact_isolation_advice_medically_exempt_primary_button_title_read_guidance_england]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .risky_contact_isolation_advice_medically_exempt_secondary_button_title]
    }
}
