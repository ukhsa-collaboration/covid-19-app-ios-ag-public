//
// Copyright © 2020 NHSX. All rights reserved.
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
    
}
