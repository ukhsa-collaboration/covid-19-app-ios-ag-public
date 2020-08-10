//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct RiskyVenueInformationScreen {
    
    var app: XCUIApplication
    
    var venueName: String
    var checkInDate: Date
    
    var title: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_title(venue: venueName, date: checkInDate)]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .checkin_risky_venue_information_description]
    }
    
    var actionButton: XCUIElement {
        app.buttons[localized: .checkin_risky_venue_information_button_title]
    }
    
}
