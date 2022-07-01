//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct ContactCaseSummaryScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        return app.staticTexts[localized: .contact_case_summary_title]
    }

    var heading: XCUIElement {
        return app.staticTexts[localized: .contact_case_summary_heading]
    }

    var ageHeader: XCUIElement {
        return app.staticTexts[localized: .age_declaration_heading]
    }

    func ageQuestion(date: Date) -> XCUIElement {
        return app.staticTexts[localized: .age_declaration_question(date: date)]
    }

    func ageAnswer(date: Date) -> XCUIElement {
        return app.staticTexts[localized: .age_declaration_yes_option_accessibility_text(date: date)]
    }

    var changeAgeButton: XCUIElement {
        return app.buttons[localized: .contact_case_summary_change_age_accessiblity_button]
    }

    var vaccinationStatusHeader: XCUIElement {
        return app.staticTexts[localized: .contact_case_vaccination_status_heading]
    }

    var fullyVaccinatedQuestion: XCUIElement {
        return app.staticTexts[localized: .contact_case_vaccination_status_all_doses_of_vaccine_question]
    }

    var fullyVaccinatedAnswer: XCUIElement {
        return app.staticTexts[localized: .contact_case_vaccination_status_all_doses_of_vaccine_yes_option_accessibility_text]
    }

    func lastDoseQuestion(date: Date) -> XCUIElement {
        return app.staticTexts[localized: .contact_case_vaccination_status_last_dose_of_vaccine_question(date: date)]
    }

    func lastDoseAnswer(date: Date) -> XCUIElement {
        return app.staticTexts[localized: .contact_case_vaccination_status_last_dose_of_vaccine_yes_option_accessibility_text(date: date)]
    }

    var changeVaccinationStatusButton: XCUIElement {
        return app.buttons[localized: .contact_case_summary_change_vaccination_status_accessiblity_button]
    }

    var submitButton: XCUIElement {
        return app.buttons[localized: .contact_case_summary_submit_button]
    }

}
