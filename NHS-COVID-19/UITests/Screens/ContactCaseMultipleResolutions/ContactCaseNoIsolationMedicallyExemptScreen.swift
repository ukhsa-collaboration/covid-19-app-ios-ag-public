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
            researchText,
            groupText,
            socialDistancingText,
            commonQuestionsLink,
            guidanceLink,
            bookAFreeTestButton,
            backToHomeButton,
        ]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt]
    }
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_info]
    }
    
    var researchText: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_research]
    }
    
    var groupText: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_group]
    }
    
    var socialDistancingText: XCUIElement {
        app.staticTexts[localized: .risky_contact_isolation_advice_medically_exempt_advice]
    }
    
    var commonQuestionsLink: XCUIElement {
        app.links[localized: .risky_contact_isolation_advice_medically_exempt_common_questions_link_title]
    }
    
    var guidanceLink: XCUIElement {
        app.links[localized: .risky_contact_isolation_advice_medically_exempt_nhs_guidance_link_title]
    }
    
    var bookAFreeTestButton: XCUIElement {
        app.buttons[localized: .risky_contact_isolation_advice_medically_exempt_primary_button_title]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .risky_contact_isolation_advice_medically_exempt_secondary_button_title]
    }
}
