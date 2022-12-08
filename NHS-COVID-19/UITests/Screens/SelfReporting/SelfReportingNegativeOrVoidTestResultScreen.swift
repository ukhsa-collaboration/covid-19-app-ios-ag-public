//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingNegativeOrVoidTestResultScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_header]
    }

    var body_one: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_body_one]
    }

    var findOutMoreLink: XCUIElement {
        app.links[localized: .self_report_negative_or_void_test_result_link_one_title]
    }

    var body_two: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_body_two]
    }

    var sectionTitle: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_subtitle]
    }

    var body_three: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_body_three]
    }

    var body_four: XCUIElement {
        app.staticTexts[localized: .self_report_negative_or_void_test_result_body_four]
    }

    var nhs111OnlineLink: XCUIElement {
        app.links[localized: .nhs111_online_opens_outside_the_app_link_button_title]
    }

    var primaryButton: XCUIElement {
        app.buttons[localized: .self_report_negative_or_void_test_result_back_to_home]
    }
}
