//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingCheckAnswersScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_check_answers_header]
    }

    var testKitTypeQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_header]
    }

    var testKitTypeAnswerOption1: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_radio_button_option_lfd]
    }

    var testKitTypeAnswerOption2: XCUIElement {
        app.staticTexts[localized: .self_report_test_kit_type_radio_button_option_pcr]
    }

    var testKitTypeChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_test_type_change_link_accessibility_label]
    }

    var testSupplierQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_header]
    }

    var testSupplierAnswerOption1: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_first_radio_button_label]
    }

    var testSupplierAnswerOption2: XCUIElement {
        app.staticTexts[localized: .self_report_test_supplier_second_radio_button_label]
    }

    var testSupplierChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_test_supplier_change_link_accessibility_label]
    }

    var testDayQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_test_date_header]
    }

    var testDayNoDateLabel: XCUIElement {
        app.staticTexts[localized: .self_report_test_date_no_date]
    }

    var testDayChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_test_date_change_link_accessibility_label]
    }

    var symptomsQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_header]
    }

    var symptomsBulletedList: [XCUIElement] {
        app.staticTexts[localized: .self_report_symptoms_bulleted_list]
    }

    var symptomsAnswerOption1: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_radio_button_option_yes]
    }

    var symptomsAnswerOption2: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_radio_button_option_no]
    }

    var symptomsChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_symptoms_change_link_accessibility_label]
    }

    var symptomsDayQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_date_header]
    }

    var symptomsDayNoDateLabel: XCUIElement {
        app.staticTexts[localized: .self_report_symptoms_date_no_date]
    }

    var symptomsDayChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_symptoms_date_change_link_accessibility_label]
    }

    var reportedResultQuestion: XCUIElement {
        app.staticTexts[localized: .self_report_reported_result_header]
    }

    var reportedResultAnswerOption1: XCUIElement {
        app.staticTexts[localized: .self_report_reported_result_radio_button_option_yes]
    }

    var reportedResultAnswerOption2: XCUIElement {
        app.staticTexts[localized: .self_report_reported_result_radio_button_option_no]
    }

    var reportedResultChangeButton: XCUIElement {
        app.links[localized: .self_report_check_answers_reported_result_change_link_accessibility_label]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .self_report_check_answers_primary_button]
    }
}
