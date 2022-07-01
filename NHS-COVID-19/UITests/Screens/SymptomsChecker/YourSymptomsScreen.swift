//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import XCTest
import Scenarios

struct YourSymptomsScreen {
    var app: XCUIApplication

    var firstQuestionNotAnswerdError: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.your_symptoms_error_title), content: localize(.your_symptoms_error_description(question: YourSymptomsViewControllerScenario.nonCardinalSymptomsHeading)))]
    }

    var secondQuestionNotAnswerdError: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.your_symptoms_error_title), content: localize(.your_symptoms_error_description(question: YourSymptomsViewControllerScenario.cardinalSymptomsHeading)))]
    }

    var noQuestionsAnswerdError: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.your_symptoms_error_title), content: localize(.your_symptoms_no_questions_answerd_error_description))]
    }

    var stepsLabel: XCUIElement {
        app.staticTexts[localized: .step_accessibility_label(index: 1, count: 3)]
    }

    var nonCardinalSymptomsHeading: XCUIElement {
        app.staticTexts[YourSymptomsViewControllerScenario.nonCardinalSymptomsHeading]
    }

    var nonCardinalSymptomsDescription: XCUIElement {
        app.staticTexts[YourSymptomsViewControllerScenario.nonCardinalSymptomsContent]
    }

    var cardinalSymptomsHeading: XCUIElement {
        app.staticTexts[YourSymptomsViewControllerScenario.cardinalSymptomsHeading]
    }

    var reportButton: XCUIElement {
        app.buttons[localized: .your_symptoms_continue_button]
    }

    func firstYesRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.your_symptoms_first_yes_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func firstNoRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.your_symptoms_first_no_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func secondYesRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.your_symptoms_second_yes_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func secondNoRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.your_symptoms_second_no_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

}
