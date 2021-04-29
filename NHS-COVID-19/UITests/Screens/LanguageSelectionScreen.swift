//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct LanguageSelectionScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .settings_language_title]
    }
    
    var systemLanguageHeader: XCUIElement {
        app.staticTexts[localized: .settings_language_system_language]
    }
    
    var customLanguageHeader: XCUIElement {
        app.staticTexts[localized: .settings_language_override_languages]
    }
    
    var currentSelectedLanguageCell: XCUIElement {
        app.tables.cells.element(boundBy: 0)
    }
    
    var newSelectedLanguageCell: XCUIElement {
        app.tables.cells.element(boundBy: 4)
    }
}
