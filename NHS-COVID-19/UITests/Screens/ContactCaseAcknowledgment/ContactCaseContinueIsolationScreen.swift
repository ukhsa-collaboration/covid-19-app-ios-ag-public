//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseContinueIsolationScreen {
    var app: XCUIApplication

    var infoBox: XCUIElement {
        app.staticTexts[localized: .contact_case_continue_isolation_info_box]
    }

    var advice: XCUIElement {
        app.staticTexts[localized: .contact_case_continue_isolation_advice]
    }

    var guidanceLink: XCUIElement {
        app.links[localized: .contact_case_continue_isolation_link_title]
    }

    var isolationListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_continue_isolation_list_item_isolation]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_continue_isolation_primary_button_title]
    }

    func daysRemanining(with days: Int) -> XCUIElement {
        let daysRemaningText = localizeForCountry(.contact_case_continue_isolation_accessibility_label(days: days))
        return app.staticTexts[verbatim: daysRemaningText]
    }
}
