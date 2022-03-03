//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import XCTest

struct StartOnboardingScreen {
    var app: XCUIApplication
    
    func scrollTo(element: XCUIElement) {
        app.scrollTo(element: element)
    }
    
    var stepTitle: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_title]
    }
    
    var stepDescription1Header: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_1_header]
    }
    
    var stepDescription1Body: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_1_description]
    }
    
    var stepDescription2Header: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_2_header]
    }
    
    var stepDescription2Body: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_2_description]
    }
    
    var stepDescription3Header: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_3_header]
    }
    
    var stepDescription3Body: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_3_description]
    }
    
    var stepDescription4Header: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_4_header]
    }
    
    var stepDescription4Body: XCUIElement {
        app.staticTexts[localized: .start_onboarding_step_4_description]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .start_onboarding_button_title]
    }
    
    var ageConfirmationAcceptButton: XCUIElement {
        app.buttons[localized: .age_confirmation_alert_accept]
    }
    
    var ageConfirmationRejectButton: XCUIElement {
        app.buttons[localized: .age_confirmation_alert_reject]
    }
    
    func ageConfirmationAlertHandled(title: String) -> XCUIElement {
        app.staticTexts[title]
    }
}
