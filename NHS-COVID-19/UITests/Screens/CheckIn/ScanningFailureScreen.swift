//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest

struct ScanningFailureScreen {

    var app: XCUIApplication

    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_scanning_failure_title]
    }

    var screenDescription: XCUIElement {
        app.staticTexts[localized: .checkin_scanning_failure_description]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .checkin_scanning_failure_button_title]
    }

}
