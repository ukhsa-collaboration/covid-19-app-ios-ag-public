//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct LocalAuthorityScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .local_authority_information_title]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .local_authority_information_description]
    }
    
    var button: XCUIElement {
        app.buttons[localized: .local_authority_information_button]
    }
}
