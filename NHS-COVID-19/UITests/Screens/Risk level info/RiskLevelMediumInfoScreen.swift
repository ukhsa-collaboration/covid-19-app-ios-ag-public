//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct RiskLevelMediumInfoScreen {
    
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .risk_level_screen_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[verbatim:  localizeForCountry(.risk_level_banner_text(postcode: "SW12", risk: "MEDIUM"))]
    }
    
    var body: XCUIElement {
        app.staticTexts[localized: .risk_level_screen_medium_body]
    }
    
    var linkToWebsiteLinkButton: XCUIElement {
        app.links[localized: .risk_level_screen_button]
    }
}
