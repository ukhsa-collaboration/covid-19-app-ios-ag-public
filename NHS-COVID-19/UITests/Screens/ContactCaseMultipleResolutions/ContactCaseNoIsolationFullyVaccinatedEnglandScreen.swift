//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseNoIsolationFullyVaccinatedEnglandScreen {
    var app: XCUIApplication
    
    var allElements: [XCUIElement] {
        [
            infoBox,
            commonQuestionsLink,
            advice,
            guidanceLink,
            isolationListItem,
            lfdListItem,
            bookAFreeTestButton,
            backToHomeButton,
        ]
    }
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_info_box]
    }
    
    var commonQuestionsLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_fully_vaccinated_common_questions_button_title]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_advice]
    }
    
    var guidanceLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_fully_vaccinated_link_title]
    }
    
    var isolationListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_list_item_info]
    }
    
    var lfdListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_list_item_lfd]
    }
    
    var bookAFreeTestButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_fully_vaccinated_primary_button_title]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_fully_vaccinated_secondary_button_title]
    }
}

struct ContactCaseNoIsolationFullyVaccinatedWalesScreen {
    var app: XCUIApplication
    
    var allElements: [XCUIElement] {
        [
            infoBox,
            commonQuestionsLink,
            advice,
            guidanceLink,
            isolationListItem,
            lfdListItem,
            secondTestAdviceListItem,
            bookAFreeTestButton,
            backToHomeButton,
        ]
    }
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_info_box_wales]
    }
    
    var commonQuestionsLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_fully_vaccinated_common_questions_button_title]
    }
    
    var advice: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_advice]
    }
    
    var guidanceLink: XCUIElement {
        app.links[localized: .contact_case_no_isolation_fully_vaccinated_link_title]
    }
    
    var isolationListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_list_item_info_wales]
    }
    
    var lfdListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_list_item_lfd_wales]
    }
    
    var secondTestAdviceListItem: XCUIElement {
        app.staticTexts[localized: .contact_case_no_isolation_fully_vaccinated_list_item_testing_with_date(date: Calendar.utc.date(from: DateComponents(year: 2021, month: 12, day: 23))!)]
    }
    
    var bookAFreeTestButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_fully_vaccinated_primary_button_title]
    }
    
    var backToHomeButton: XCUIElement {
        app.buttons[localized: .contact_case_no_isolation_fully_vaccinated_secondary_button_title]
    }
}
