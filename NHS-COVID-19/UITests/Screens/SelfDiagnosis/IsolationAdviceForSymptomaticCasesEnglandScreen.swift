//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct IsolationAdviceForSymptomaticCasesEnglandScreen {
    var app: XCUIApplication
    
    var allElements: [XCUIElement] {
        [
            heading,
            infoBox,
            descriptionLabel,
            continueButton,
        ]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .isolation_advice_symptomatic_title_england]
    }
    
    var infoBox: XCUIElement {
        app.staticTexts[localized: .isolation_advice_symptomatic_info_england]
    }
    
    var descriptionLabel: XCUIElement {
        app.staticTexts[localized: .isolation_advice_symptomatic_description_england]
    }
    
    var continueButton: XCUIElement {
        app.buttons[localized: .isolation_advice_symptomatic_primary_button_title_england]
    }
    
}
