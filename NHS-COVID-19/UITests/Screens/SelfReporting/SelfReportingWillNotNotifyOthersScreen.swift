//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingWillNotNotifyOthersScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_will_not_notify_others_header]
    }

    var body: XCUIElement {
        app.staticTexts[localized: .self_report_will_not_notify_others_body]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }
}
