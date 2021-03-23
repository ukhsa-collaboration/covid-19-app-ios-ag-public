//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct ShareKeysConfirmationScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .share_keys_confirmation_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .share_keys_confirmation_heading]
    }
    
    var privacyNotice: XCUIElement {
        app.staticTexts[localized: .share_keys_confirmation_privacy_notice]
    }
    
    var informationTitle: XCUIElement {
        app.staticTexts[localized: .share_keys_confirmation_info_title]
    }
    
    var informationBody: XCUIElement {
        app.staticTexts[localized: .share_keys_confirmation_info_body]
    }
    
    var iUnderstand: XCUIElement {
        app.buttons[localized: .share_keys_confirmation_i_understand]
    }
    
    var back: XCUIElement {
        app.buttons[localized: .back]
    }
    
    func iUnderstandAlert(_ title: String) -> XCUIElement {
        app.staticTexts[title]
    }
    
    func backAlert(_ title: String) -> XCUIElement {
        app.staticTexts[title]
    }
}
