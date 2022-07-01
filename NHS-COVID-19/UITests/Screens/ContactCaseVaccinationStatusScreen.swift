//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct ContactCaseVaccinationStatusScreen {
    let app: XCUIApplication
    let lastDoseDate: Date

    var allStaticElements: [XCUIElement] {
        [
            title,
            heading,
            description,
            fullyVaccinatedQuestion,
            fullyVaccinatedDescription,
            readMoreAboutVaccinesLink,
            confirmButton,
        ]
    }

    var title: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_title]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_heading]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_description]
    }

    var fullyVaccinatedQuestion: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_all_doses_of_vaccine_question]
    }

    var fullyVaccinatedDescription: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_all_doses_of_vaccine_description]
    }

    var readMoreAboutVaccinesLink: XCUIElement {
        app.links[localized: .contact_case_vaccination_status_aproved_vaccines_link_title]
    }

    func yesFullyVaccinatedRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func noFullyVaccinatedRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option_accessibility_text)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var lastDoseDateQuestion: XCUIElement {
        app.staticTexts[localized: .contact_case_vaccination_status_last_dose_of_vaccine_question(date: lastDoseDate)]
    }

    func yesLastDoseDateRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option_accessibility_text(date: lastDoseDate))
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func noLastDoseDateRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option_accessibility_text(date: lastDoseDate))
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var clinicalTrialQuestion: XCUIElement {
        app.staticTexts[localized: .exposure_notification_clinical_trial_question]
    }

    func noClinicalTrialRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.exposure_notification_clinical_trial_no_content_description)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var medicallyExemptQuestion: XCUIElement {
        app.staticTexts[localized: .exposure_notification_medically_exempt_question]
    }

    func noMedicallyExemptRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.exposure_notification_medically_exempt_no_content_description)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    func yesMedicallyExemptRadioButton(selected: Bool) -> XCUIElement {
        let title = localize(.exposure_notification_medically_exempt_yes_content_description)
        let value = selected ? localize(.radio_button_checked) : localize(.radio_button_unchecked)
        return app.buttons[localized: .radio_button_accessibility_label(value: value, content: title)]
    }

    var confirmButton: XCUIElement {
        app.buttons[localized: .contact_case_vaccination_status_confirm_button_title]
    }

    var error: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.contact_case_vaccination_status_error_title), content: localize(.contact_case_vaccination_status_error_description))]
    }
}
