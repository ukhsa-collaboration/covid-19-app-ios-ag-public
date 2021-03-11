//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

struct LinkTestResultWithDCTScreen {
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .link_test_result_title]
    }
    
    var header: XCUIElement {
        app.staticTexts[localized: .link_test_result_header]
    }
    
    var description: XCUIElement {
        app.staticTexts[localized: .link_test_result_description]
    }
    
    var subheading: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_heading]
    }
    
    var exampleLabel: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_example]
    }
    
    var error: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_invalid_error]
    }
    
    var scenarioError: XCUIElement {
        app.staticTexts[LinkTestResultScreenScenario.invalidCodeError]
    }
    
    var testCodeTextField: XCUIElement {
        app.textFields[localized: .link_test_result_enter_code_textfield_label]
    }
    
    var continueButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .link_test_result_button_title]
    }
    
    var cancelButton: XCUIElement {
        app.windows["MainWindow"].buttons[localized: .cancel]
    }
    
    var dctHeading: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_heading]
    }
    
    var dctParagraph: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_paragraph]
    }
    
    var dctBulletedListTitle: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_bulleted_list_title]
    }
    
    var dctBulletedList: [XCUIElement] {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_bulleted_list]
    }
    
    var dctCheckBoxText: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_checkbox]
    }
    
    func checkBox(checked: Bool) -> XCUIElement {
        let value = checked ? localize(.symptom_card_checked) : localize(.symptom_card_unchecked)
        let title = localize(.link_test_result_enter_code_daily_contact_testing_checkbox)
        return app.buttons[localized: .local_authority_card_checkbox_accessibility_label(value: value, content: title)]
    }
    
    var dctTopErrorBox: XCUIElement {
        app.staticTexts[localized: .link_test_result_enter_code_daily_contact_testing_checkbox]
    }
    
    enum ErrorBoxType {
        case noneEntered, bothEntered
    }
    
    func errorBox(errorType: ErrorBoxType) -> XCUIElement {
        switch errorType {
        case .bothEntered:
            return app.staticTexts[
                localized: .symptom_card_accessibility_label(
                    heading: localize(.link_test_result_enter_code_daily_contact_testing_top_erorr_box_heading),
                    content: localize(.link_test_result_enter_code_daily_contact_testing_top_erorr_box_text_both_entered)
                )
            ]
        case .noneEntered:
            return app.staticTexts[
                localized: .symptom_card_accessibility_label(
                    heading: localize(.link_test_result_enter_code_daily_contact_testing_top_erorr_box_heading),
                    content: localize(.link_test_result_enter_code_daily_contact_testing_top_erorr_box_text_none_entered)
                )
            ]
        }
    }
    
}
