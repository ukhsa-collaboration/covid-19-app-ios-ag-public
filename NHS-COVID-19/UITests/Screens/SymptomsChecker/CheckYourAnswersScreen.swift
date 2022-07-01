//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import XCTest
import Scenarios

struct CheckYourAnswersScreen {
    var app: XCUIApplication

    var stepsLabel: XCUIElement {
        app.staticTexts[localized: .step_accessibility_label(index: 3, count: 3)]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .check_answers_heading]
    }

    var firstCardHeading: XCUIElement {
        app.staticTexts[localized: .your_symptoms_title]
    }

    var firstChangeButton: XCUIElement {
        app.buttons[CheckYourAnswersViewControllerScenario.firstChangeButtonId]
    }

    var nonCardinalSymptomsHeading: XCUIElement {
        app.staticTexts[CheckYourAnswersViewControllerScenario.nonCardinalSymptomsHeading]
    }

    var nonCardinalSymptomsDescription: XCUIElement {
        app.staticTexts[CheckYourAnswersViewControllerScenario.nonCardinalSymptomsContent]
    }

    var cardinalSymptomsHeading: XCUIElement {
        app.staticTexts[CheckYourAnswersViewControllerScenario.cardinalSymptomsHeading]
    }

    var secondCardHeading: XCUIElement {
        app.staticTexts[localized: .how_you_feel_header]
    }

    var secondChangeButton: XCUIElement {
        app.buttons[CheckYourAnswersViewControllerScenario.secondChangeButtonId]
    }

    var howYouFeelQuestion: XCUIElement {
        app.staticTexts[localized: .how_you_feel_description]
    }

    var submitButton: XCUIElement {
        app.buttons[localized: .check_answers_submit_button]
    }

    var changeButtonAlertText: XCUIElement {
        app.staticTexts[CheckYourAnswersViewControllerScenario.changeButtonTapped]
    }

    var submitButtonAlertText: XCUIElement {
        app.staticTexts[CheckYourAnswersViewControllerScenario.sumbitAnswersTapped]
    }
}
