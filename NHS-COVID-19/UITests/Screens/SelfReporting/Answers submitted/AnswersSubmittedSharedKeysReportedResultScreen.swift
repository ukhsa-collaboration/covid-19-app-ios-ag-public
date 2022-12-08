//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct AnswersSubmittedSharedKeysReportedResultScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_answers_submitted_shared_keys_header]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .self_report_answers_submitted_shared_keys_reported_description]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }
}
