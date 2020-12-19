//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct PositiveSymptomsScreen {
    var app: XCUIApplication
    
    var pleaseIsolateLabel: XCUIElement {
        app.staticTexts[localize(.positive_symptoms_please_isolate_accessibility_label(days: 7))]
    }
    
    var indicationLabel: XCUIElement {
        app.staticTexts[localized: .positive_symptoms_you_might_have_corona]
    }
    
    var explanationLabel: [XCUIElement] {
        app.staticTexts[localized: .positive_symptoms_explanation]
    }
    
    var bookTestButton: XCUIElement {
        app.buttons[localized: .positive_symptoms_corona_test_button]
    }
    
    var furtherAdviceButton: XCUIElement {
        app.links[localized: .end_of_isolation_online_services_link]
    }
    
    var exposureFAQLink: XCUIElement {
        app.links[localized: .exposure_faqs_link_button_title]
    }
}
