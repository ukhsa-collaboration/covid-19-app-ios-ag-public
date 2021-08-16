//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct PrivacyScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .privacy_title]
    }
    
    var privacyDespcription: [XCUIElement] {
        app.staticTexts[localized: .privacy_description_paragraph1]
    }
    
    var dataDespcription1: XCUIElement {
        app.staticTexts[localized: .privacy_description_paragraph2]
    }
    
    var dataDespcription2: XCUIElement {
        app.staticTexts[localized: .privacy_description_paragraph4]
    }
    
    var privacyNotice: XCUIElement {
        app.links[localized: .privacy_notice_label]
    }
    
    var termsOfUse: XCUIElement {
        app.links[localized: .terms_of_use_label]
    }
    
    var linksHeader: XCUIElement {
        app.staticTexts[localized: .privacy_links_accessibility_label]
    }
    
    var agreeButton: XCUIElement {
        app.buttons[localized: .privacy_yes_button]
    }
    
    var noThanksButton: XCUIElement {
        app.buttons[localized: .privacy_no_button_accessibility_label]
    }
    
    var privacyHeader: XCUIElement {
        app.staticTexts[localized: .privacy_header]
    }
    
    var dataHeader: XCUIElement {
        app.staticTexts[localized: .data_header]
    }
}
