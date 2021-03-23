//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct CheckInConfirmationScreen {
    
    var app: XCUIApplication
    
    func dateTime(_ date: Date) -> XCUIElement {
        app.staticTexts[localized: .checkin_confirmation_date(date: date)]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .checkin_confirmation_simplified_explanation]
    }
    
    var homeButton: XCUIElement {
        app.buttons[localized: .checkin_confirmation_button_title]
    }
    
    var wrongButton: XCUIElement {
        app.buttons[localized: .checkin_cancel_checkin_button_title]
    }
    
    var homeAlert: XCUIElement {
        app.staticTexts[CheckInConfirmationScreenScenario.didTapGoHome]
    }
    
    var wrongAlert: XCUIElement {
        app.staticTexts[CheckInConfirmationScreenScenario.didTapWrongCheckIn]
    }
    
    func thankYouText(with venueName: String) -> XCUIElement {
        let thankYouText = localize(.checkin_confirmation_thankyou(venue: venueName))
        return app.staticTexts[verbatim: thankYouText]
    }
}
