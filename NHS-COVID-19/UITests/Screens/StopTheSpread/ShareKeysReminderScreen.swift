//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct ShareKeysReminderScreen {
    var app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_reminder_screen_heading]
    }

    var privacyBanner: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_reminder_screen_privacy_notice]
    }

    var subHeading: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_reminder_screen_reconsider_sharing_heading]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .share_keys_and_venues_reminder_screen_reconsider_sharing_body]
    }

    var shareButton: XCUIElement {
        app.buttons[localized: .share_keys_and_venues_reminder_screen_back_to_share_button_title]
    }

    var doNotShareButton: XCUIElement {
        app.buttons[localized: .share_keys_and_venues_reminder_screen_do_not_share_button_title]
    }

}
