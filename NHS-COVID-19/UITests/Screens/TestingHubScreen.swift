//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct TestingHubScreen {
    let app: XCUIApplication
    
    var bookFreeTestButton: XCUIElement {
        app.buttons[TestingHubAccessibilityID.bookFreeTestButton]
    }
    
    var findOutAboutTestingLinkButton: XCUIElement {
        app.links[TestingHubAccessibilityID.findOutAboutTestingLinkButton]
    }
    
    var enterTestResultButton: XCUIElement {
        app.buttons[TestingHubAccessibilityID.enterTestResultButton]
    }
}
