//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseNoIsolationUnderAgeLimitScreen {
    var app: XCUIApplication
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_under_age_limit_info_box]
    }
    
    var commonQuestionsLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_under_age_limit_common_questions_button_title]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_under_age_limit_advice]
    }
    
    var guidanceLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_under_age_limit_link_title]
    }
    
    var isolationListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_under_age_limit_list_item_adult]
    }
    
    var lfdListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_under_age_limit_list_item_lfd]
    }
    
    var bookAFreeTestButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_under_age_limit_primary_button_title]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_under_age_limit_secondary_button_title]
    }
}
