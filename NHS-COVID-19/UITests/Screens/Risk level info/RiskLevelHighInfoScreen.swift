//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct RiskLevelHighInfoScreen {
    
    var app: XCUIApplication
    
    var screenTitle: XCUIElement {
        app.staticTexts[localized: .risk_level_screen_title]
    }
}
