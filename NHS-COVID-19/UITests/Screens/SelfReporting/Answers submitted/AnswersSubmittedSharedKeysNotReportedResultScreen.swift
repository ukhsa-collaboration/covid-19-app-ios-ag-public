//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct AnswersSubmittedSharedKeysNotReportedResultScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_answers_submitted_shared_keys_header]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .self_report_answers_submitted_shared_keys_not_reported_description]
    }

    var infoBoxLabel: XCUIElement {
        app.staticTexts[localized: .self_report_answers_submitted_not_reported_info_label]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }
}
