//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct ContactCaseAcknowledgementScreen {
    var app: XCUIApplication
    
    var explanation1: XCUIElement {
        app.staticTexts[localized: .exposure_acknowledgement_explaination_1]
    }
    
    var explanation2: XCUIElement {
        app.staticTexts[localized: .exposure_acknowledgement_explaination_2]
    }
    
    var faqslinkLabel: XCUIElement {
        app.staticTexts[localized: .exposure_faqs_link_label]
    }
    
    var faqsLink: XCUIElement {
        app.links[localized: .exposure_faqs_link_button_title]
    }
    
    var acknowledgementLinkLabel: XCUIElement {
        app.staticTexts[localized: .exposure_acknowledgement_link_label]
    }
    
    var acknowledgementlink: XCUIElement {
        app.links[localized: .exposure_acknowledgement_link]
    }
    
    var acknowledgementButton: XCUIElement {
        app.buttons[localized: .exposure_acknowledgement_button]
    }
}
