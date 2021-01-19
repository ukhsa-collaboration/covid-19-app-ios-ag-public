//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct SettingsScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .settings_title]
    }
    
    var languageRow: XCUIElement {
        app.cells[localized: .settings_row_language]
    }
}
