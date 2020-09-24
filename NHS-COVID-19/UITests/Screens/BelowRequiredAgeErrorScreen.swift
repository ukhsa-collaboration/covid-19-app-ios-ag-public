//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct BelowRequiredAgeErrorScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .below_required_age_title]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .below_required_age_description]
    }
}
