//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct RiskLevelLowInfoScreen {
    
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .risk_level_screen_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[verbatim: localizeForCountry(.risk_level_banner_text(postcode: "SW12", risk: "LOW"))]
    }
    
    var body: XCUIElement {
        app.staticTexts[verbatim: localizeForCountry(.risk_level_screen_low_body)]
    }
    
    var linkToWebsiteLinkButton: XCUIElement {
        app.links[localized: .risk_level_screen_button]
    }
}
