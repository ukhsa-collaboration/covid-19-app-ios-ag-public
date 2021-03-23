//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct MyDataScreen {
    
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .mydata_screen_title]
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
    
    func testResult(testResult: String) -> XCUIElement {
        app.staticTexts[verbatim: testResult]
    }
    
    func cellDate(date: Date) -> XCUIElement {
        app.staticTexts[localized: .mydata_date_description(date: date)]
    }
    
    func cellTestKitType(testKitType: String) -> XCUIElement {
        app.staticTexts[verbatim: testKitType]
    }
}
