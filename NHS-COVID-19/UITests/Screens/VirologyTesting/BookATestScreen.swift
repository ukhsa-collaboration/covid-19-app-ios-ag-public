//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct BookATestScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .virology_book_a_test_title]
    }
    
    var heading: XCUIElement {
        app.staticTexts[localized: .virology_book_a_test_heading]
    }
    
    var description: [XCUIElement] {
        app.staticTexts[localized: .virology_book_a_test_description]
    }
    
    var paragraph4: XCUIElement {
        app.staticTexts[localized: .virology_book_a_test_paragraph4]
    }
    
    var paragraph5: XCUIElement {
        app.staticTexts[localized: .virology_book_a_test_paragraph5]
    }
    
    var testingPrivacyNotice: XCUIElement {
        app.links[localized: .virology_book_a_test_testing_privacy_notice]
    }
    
    var appPrivacyNotice: XCUIElement {
        app.links[localized: .virology_book_a_test_app_privacy_notice]
    }
    
    var bookATestForSomeoneElse: XCUIElement {
        app.links[localized: .virology_book_a_test_book_a_test_for_someone_else]
    }
    
    var button: XCUIElement {
        app.links[localized: .virology_book_a_test_button]
    }
    
    var cancelButton: XCUIElement {
        app.buttons[localized: .cancel]
    }
}
