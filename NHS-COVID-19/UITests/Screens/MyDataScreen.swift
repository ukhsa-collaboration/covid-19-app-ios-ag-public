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
        #warning("This is currently referencing an `accessibilityIdentifier`. In future this should go away once they have different `accessibilityLabels`")
        return app.buttons.matching(identifier: "venue_history_edit_button").firstMatch
    }
    
    var doneVenueHistoryButton: XCUIElement {
        #warning("This is currently referencing an `accessibilityIdentifier`. In future this should go away once they have different `accessibilityLabels`")
        return app.buttons.matching(identifier: "venue_history_edit_button").firstMatch
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
        #warning("This is currently referencing an `accessibilityIdentifier`. In future this should go away once they have different `accessibilityLabels`")
        return app.buttons.matching(identifier: "postcode_or_local_authority_edit_button").firstMatch
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
