//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class BasicLocalInformationScreen {
    let app: XCUIApplication
    
    init(app: XCUIApplication) {
        self.app = app
    }
    
    var cancelButton: XCUIElement {
        app.buttons[localized: .cancel]
    }
    
    var primaryButton: XCUIElement {
        app.buttons[localized: .local_information_screen_primary_button]
    }
}

final class ParagraphsOnlyLocalInformationScreen: BasicLocalInformationScreen {
    private typealias Content = LocalInformationScreenParagraphsOnlyScenario.Content
    
    var header: XCUIElement {
        app.staticTexts[verbatim: Content.header.applyCurrentLanguageDirection()]
    }
    
    var paragraph1: XCUIElement {
        app.staticTexts[verbatim: Content.Body.paragraph1.applyCurrentLanguageDirection()]
    }
    
    var linkButton1: XCUIElement {
        app.links[verbatim: Content.Body.link1.title.applyCurrentLanguageDirection()]
    }
    
    var paragraph2: XCUIElement {
        app.staticTexts[verbatim: Content.Body.paragraph2.applyCurrentLanguageDirection()]
    }
    
    var linkButton2: XCUIElement {
        app.links[verbatim: Content.Body.link2.title.applyCurrentLanguageDirection()]
    }
}
