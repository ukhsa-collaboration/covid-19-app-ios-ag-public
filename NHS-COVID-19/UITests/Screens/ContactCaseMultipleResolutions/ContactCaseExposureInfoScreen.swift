//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseExposureInfoScreen {
    var app: XCUIApplication
    
    var headingText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_title]
    }
    
    var infoBoxText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_information]
    }
    
    var ifYouHaveSymptomsText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_if_you_have_symptoms]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .contact_case_exposure_info_screen_continue_button]
    }
    
    var alertOnTappingContinueButton: XCUIElement {
        app.staticTexts["'Continue' button tapped"]
    }
    
}
