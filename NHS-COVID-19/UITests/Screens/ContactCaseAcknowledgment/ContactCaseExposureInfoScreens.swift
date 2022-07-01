//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest

struct ContactCaseExposureInfoEnglandScreen {
    var app: XCUIApplication
    var date: Date

    var allElements: [XCUIElement] {
        [
            headingText,
            exposureDateLine,
            accordionHeading,
            infoBoxText,
            continueButton,
        ]
    }

    var headingText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_title_england]
    }

    var infoBoxText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_information_england]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .contact_case_exposure_info_screen_continue_button_england]
    }

    var alertOnTappingContinueButton: XCUIElement {
        app.staticTexts["'Continue' button tapped"]
    }

    var accordionHeading: XCUIElement {
        app.buttons[localized: .contact_case_exposure_info_screen_how_close_contacts_are_calculated_heading_england]
    }

    var accordionBodyElements: [XCUIElement] {
        localizeAndSplit(.contact_case_exposure_info_screen_how_close_contacts_are_calculated_body_england)
            .map {
                app
                    .staticTexts
                    .element(matching: NSPredicate(format: "label LIKE %@", $0))
            }
    }

    var exposureDateLine: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_exposure_date_england(date: date)]
    }

}

struct ContactCaseExposureInfoWalesScreen {
    var app: XCUIApplication
    var date: Date

    func allElements(isIndexCase: Bool) -> [XCUIElement] {
        if isIndexCase {
            return [
                headingText,
                exposureDateLine,
                accordionHeading,
                continueButton,
            ]
        } else {
            return [
                headingText,
                exposureDateLine,
                accordionHeading,
                infoBoxText,
                ifYouHaveSymptomsText,
                continueButton,
            ]
        }
    }

    var headingText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_title]
    }

    var infoBoxText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_information]
    }

    var ifYouHaveSymptomsText: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_if_you_have_symptoms]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .contact_case_exposure_info_screen_continue_button]
    }

    var alertOnTappingContinueButton: XCUIElement {
        app.staticTexts["'Continue' button tapped"]
    }

    var accordionHeading: XCUIElement {
        app.buttons[localized: .contact_case_exposure_info_screen_how_close_contacts_are_calculated_heading]
    }

    var accordionBodyElements: [XCUIElement] {
        localizeAndSplit(.contact_case_exposure_info_screen_how_close_contacts_are_calculated_body)
            .map {
                app
                    .staticTexts
                    .element(matching: NSPredicate(format: "label LIKE %@", $0))
            }
    }

    var exposureDateLine: XCUIElement {
        app.staticTexts[localized: .contact_case_exposure_info_screen_exposure_date(date: date)]
    }

}
