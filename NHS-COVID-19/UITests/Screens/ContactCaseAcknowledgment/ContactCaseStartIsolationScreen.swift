//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseStartIsolationScreenEngland {
    var app: XCUIApplication
    var isolationPeriod: Int
    var daysSinceEncounter: Int
    var remainingDays: Int

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

struct ContactCaseStartIsolationScreenWales {
    var app: XCUIApplication
    var isolationPeriod: Int
    var daysSinceEncounter: Int
    var remainingDays: Int
    var secondTestAdviceDate: Date

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

    var secondTestListItem: XCUIElement {
        let secondTestAdviceText = localize(.contact_case_start_isolation_list_item_testing_with_date(date: secondTestAdviceDate))
        return app.staticTexts[verbatim: secondTestAdviceText]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_start_isolation_secondary_button_title]
    }

    var getTestedButton: XCUIElement {
        app.links[localized: .contact_case_start_isolation_primary_button_title_wales]
    }

    func daysRemaining(with days: Int) -> XCUIElement {
        let daysRemaningText = localize(.contact_case_start_isolation_accessibility_label(days: days))
        return app.staticTexts[verbatim: daysRemaningText]
    }

}
