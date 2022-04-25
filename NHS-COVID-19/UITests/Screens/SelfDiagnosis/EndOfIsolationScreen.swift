//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct EndOfIsolationScreen {
    var app: XCUIApplication
    
    let numberOfDaysForIsolation = 5
    let numberOfDaysForIsolationPlusOne = 6
    
    // MARK: - Index and Contact Cases (England)
    var title: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_title]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_if_have_symptom_warning]
    }
    
    // MARK: - Index and Contact Cases (Wales)
    
    var titleIndexCaseWales: XCUIElement {
        app.staticTexts[localized: .your_isolation_are_ending_soon_wales]
    }
    
    var titleContactCaseWales: XCUIElement {
        app.staticTexts[localized: .end_of_isolation_isolate_title]
    }
    
    var calloutBoxIndexCaseWales: XCUIElement {
        app.staticTexts[localized: .expiration_notification_testing_advice_wales_before_isolation_ended_wales]
    }
    
    var openGuidanceLinkButton: XCUIElement {
        app.links[localized: .expiration_notification_link_button_title_wales]
    }
    
    // MARK: - Shared views between all cases (index and contact) in England and Wales
    var onlineServicesLink: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var returnHomeButton: XCUIElement {
        app.buttons[localized: .end_of_isolation_corona_back_to_home_button]
    }
    
}
