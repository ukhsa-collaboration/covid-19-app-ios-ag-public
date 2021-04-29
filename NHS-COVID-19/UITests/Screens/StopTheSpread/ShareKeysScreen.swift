//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct ShareKeysScreen {
    var app: XCUIApplication
    
    // MARK: Navigation bar
    
    var title: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_title]
    }
    
    // MARK: Screen heading
    
    var heading: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_heading]
    }
    
    var privacyBanner: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_privacy_notice]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .share_keys_and_venues_share_keys_button]
    }
    
    // MARK: How does it help?
    
    var howDoesItHelpHeading: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_how_it_helps_heading]
    }
    
    var howDoesItHelpBody: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_how_it_helps_body]
    }
    
    // MARK: What is a random ID?
    
    var whatIsARandomIDHeading: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_what_is_a_random_id_heading]
    }
    
    var whatIsARandomIDBody: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_share_keys_what_is_a_random_id_body]
    }
    
    // MARK: Footer button
    
    var notifyButton: XCUIElement {
        app.buttons[localized: .share_keys_and_venues_share_keys_button]
    }
    
}
