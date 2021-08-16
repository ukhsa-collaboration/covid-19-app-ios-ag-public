//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseStartIsolationScreen {
    var app: XCUIApplication
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .contact_case_start_isolation_info_box]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .contact_case_start_isolation_advice]
    }
    
    var guidanceLink: XCUIElement {
        app.links[localized: .contact_case_start_isolation_link_title]
    }
    
    var isolationListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_start_isolation_list_item_isolation]
    }
    
    var lfdListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_start_isolation_list_item_lfd]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_start_isolation_secondary_button_title]
    }
    
    var bookAFreeTestButton: XCUIElement {
        app.buttons[localized: .contact_case_start_isolation_primary_button_title]
    }
    
    func daysRemanining(with days: Int) -> XCUIElement {
        let daysRemaningText = localize(.contact_case_start_isolation_accessibility_label(days: days))
        return app.staticTexts[verbatim: daysRemaningText]
    }
}
