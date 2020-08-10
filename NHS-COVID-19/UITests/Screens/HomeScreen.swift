//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

struct HomeScreen {
    var app: XCUIApplication
    
    var riskLevelBanner: XCUIElement {
        app.staticTexts[localized: .risk_level_banner_text(postcode: "SW12", risk: "LOW")]
    }
    
    var aboutButton: XCUIElement {
        app.buttons[localized: .home_about_button_title_accessibility_label]
    }
    
    var diagnoisButton: XCUIElement {
        app.buttons[localized: .home_diagnosis_button_title]
    }
    
    var adviceButton: XCUIElement {
        app.links[localized: .home_default_advice_button_title]
    }
    
    var testingInformationButton: XCUIElement {
        app.buttons[localized: .home_testing_information_button_title]
    }
    
    var checkInButton: XCUIElement {
        app.buttons[localized: .home_checkin_button_title]
    }
    
    var moreInfoButton: XCUIElement {
        app.links[localized: .risk_level_more_info_accessibility_label]
    }
    
    var aboutTracingButton: XCUIElement {
        app.links[localized: .home_about_the_app_button_title]
    }
    
    var earlyAccessLabel: XCUIElement {
        app.staticTexts[localized: .home_early_access_label]
    }
}
