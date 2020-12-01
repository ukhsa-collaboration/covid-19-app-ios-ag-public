//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct MyDataScreen {
    
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .mydata_title]
    }
    
    var postcodeSectionHeader: XCUIElement {
        app.staticTexts[localized: .mydata_section_postcode_description]
    }
    
    var localAuthoritySectionHeader: XCUIElement {
        app.staticTexts[localized: .mydata_section_LocalAuthority_description]
    }
    
    var testResultSectionHeader: XCUIElement {
        app.staticTexts[localized: .mydata_section_test_result_description]
    }
    
    var editVenueHistoryButton: XCUIElement {
        app.buttons.matching(identifier: localize(.mydata_venue_history_edit_button_title)).element(boundBy: 3)
    }
    
    var doneVenueHistoryButton: XCUIElement {
        app.buttons[localized: .mydata_venue_history_done_button_title].firstMatch
    }
    
    var deleteDataButton: XCUIElement {
        app.buttons[localized: .mydata_data_deletion_button_title]
    }
    
    func postcodeCell(postcode: String) -> XCUIElement {
        app.staticTexts[verbatim: postcode]
    }
    
    func postcodeAndLocalAuthorityCell(postcode: String, localAuthority: String) -> [XCUIElement] {
        [app.staticTexts[verbatim: postcode], app.staticTexts[verbatim: localAuthority]]
    }
    
    var editPostcodeButton: XCUIElement {
        app.buttons.matching(identifier: localize(.mydata_venue_history_edit_button_title)).element(boundBy: 2)
    }
    
    func testResult(testResult: String) -> XCUIElement {
        app.staticTexts[verbatim: testResult]
    }
    
    func cellDate(date: Date) -> XCUIElement {
        app.staticTexts[localized: .mydata_date_description(date: date)]
    }
    
    var cellDeleteButton: XCUIElement {
        app.tables.buttons[localized: .delete]
    }
    
    var deleteDataAlert: XCUIElement {
        app.buttons[localized: .mydata_delete_data_alert_title]
    }
    
    var deleteDataAlertConfirmationButton: XCUIElement {
        app.buttons[localized: .mydata_delete_data_alert_button_title]
    }
}
