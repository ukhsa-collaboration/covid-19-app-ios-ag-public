//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct FinancialSupportScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .financial_support_title]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .financial_support_description]
    }
    
    var financialHelpEnglandLinkDescription: XCUIElement {
        app.staticTexts[localized: .financial_support_help_england_link_description]
    }
    
    var financialHelpEnglandLinkButton: XCUIElement {
        app.links[localized: .financial_support_help_england_link_title]
    }
    
    var financialHelpWalesLinkDescription: XCUIElement {
        app.staticTexts[localized: .financial_support_help_wales_link_description]
    }
    
    var financialHelpWalesLinkButton: XCUIElement {
        app.links[localized: .financial_support_help_wales_link_title]
    }
    
    var checkEligibilityLinkButton: XCUIElement {
        app.links[localized: .financial_support_check_eligibility]
    }
}
