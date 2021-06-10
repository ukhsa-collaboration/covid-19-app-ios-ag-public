//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct HomeAnimationsScreen {
    var app: XCUIApplication
    
    var homeAnimationsToggleOnDescription: XCUIElement {
        app.switches[localized: .home_animations_toggle_description_on]
    }
    
    var homeAnimationsToggleOffDescription: XCUIElement {
        app.switches[localized: .home_animations_toggle_description_off]
    }
    
    var title: XCUIElement {
        app.staticTexts[localized: .home_animations_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .home_animations_heading]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .home_animations_description]
    }
    
    var alertTitle: XCUIElement {
        app.staticTexts[localized: .home_animations_alert_view_title]
    }
    
    var alertDescription: XCUIElement {
        app.staticTexts[localized: .home_animations_alert_view_description]
    }
    
    var alertDismissButton: XCUIElement {
        app.buttons[localized: .ok]
    }
}
