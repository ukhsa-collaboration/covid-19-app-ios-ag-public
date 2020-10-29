//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct RiskyVenueIsolationAcknowledgementScreen {
    var app: XCUIApplication
    
    func pleaseIsolate(daysRemaining: Int) -> XCUIElement {
        app.staticTexts[localized: .risky_venue_isolation_title_accessibility(days: daysRemaining)]
    }
    
    var warningBox: XCUIElement {
        app.staticTexts[localized: .risky_venue_isolation_warning]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .risky_venue_isolation_description]
    }
    
    var linkLabel: XCUIElement {
        app.staticTexts[localized: .exposure_acknowledgement_link_label]
    }
    
    var link: XCUIElement {
        app.links[localized: .exposure_acknowledgement_link]
    }
    
    var button: XCUIElement {
        app.buttons[localized: .exposure_acknowledgement_button]
    }
}
