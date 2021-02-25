//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct UnrecoverableErrorScreen {
    var app: XCUIApplication
    
    var pageTitleLabel: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_page_title]
    }
    
    var heading1: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_heading_1]
    }
    
    var bulletedList: [XCUIElement] {
        app.staticTexts[localized: .unrecoverable_error_bulleted_list]
    }
    
    var heading2: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_heading_2]
    }
    
    var description2: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_description_2]
    }
    
    var link: XCUIElement {
        app.links[localized: .unrecoverable_error_link]
    }
    
    var linkAlertTitle: XCUIElement {
        app.staticTexts[UnrecoverableErrorScreenScenario.linkAlertTitle]
    }
}
