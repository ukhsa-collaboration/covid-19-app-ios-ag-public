//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PlodTestResultScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .plod_test_result_title]
    }
    
    var subtitle: XCUIElement {
        app.staticTexts[localized: .plod_test_result_subtitle]
    }
    
    var warning: XCUIElement {
        app.staticTexts[localized: .plod_test_result_warning]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .plod_test_result_description]
    }
    
    var primaryButton: XCUIElement {
        app.buttons[localized: .plod_test_result_button_title]
    }
}
