//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct GetAFreeTestKitScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .get_a_free_test_kit_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .get_a_free_test_kit_heading]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .get_a_free_test_kit_description]
    }
    
    var cancelButton: XCUIElement {
        app.buttons[localized: .get_a_free_test_kit_cancel_button]
    }
    
    var submitButton: XCUIElement {
        app.links[localized: .get_a_free_test_kit_submit_button]
    }
}
