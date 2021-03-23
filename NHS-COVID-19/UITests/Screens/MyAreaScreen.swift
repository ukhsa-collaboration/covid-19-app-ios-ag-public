//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct MyAreaScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .my_area_title]
    }
    
    var edit: XCUIElement {
        app.buttons[localized: .my_area_edit_button_title]
    }
    
    var postcodeCellTitle: XCUIElement {
        app.cells[localized: .my_area_postcode_disctrict]
    }
    
    func postcodeCellValue(postcode: String) -> XCUIElement {
        app.staticTexts[verbatim: postcode]
    }
    
    var localAuthorityCellTitle: XCUIElement {
        app.cells[localized: .my_area_local_authority]
    }
    
    func localAuthorityCellValue(localAuthority: String) -> XCUIElement {
        app.staticTexts[verbatim: localAuthority]
    }
    
}
