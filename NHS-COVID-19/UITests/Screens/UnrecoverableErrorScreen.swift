//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct UnrecoverableErrorScreen {
    var app: XCUIApplication
    
    var pageTitleLabel: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_page_title]
    }
    
    var titleLabel: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_title]
    }
    
    var descriptionLabel: XCUIElement {
        app.staticTexts[localized: .unrecoverable_error_description]
    }
    
}
