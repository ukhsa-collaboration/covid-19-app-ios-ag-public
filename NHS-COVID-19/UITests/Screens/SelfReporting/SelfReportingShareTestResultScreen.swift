//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct SelfReportingShareTestResultScreen {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts[localized: .self_report_share_result_header]
    }

    var subheader: XCUIElement {
        app.staticTexts[localized: .self_report_share_result_subheader]
    }

    var body: XCUIElement {
        app.staticTexts[localized: .self_report_share_result_body]
    }

    var privacyBox: XCUIElement {
        app.staticTexts[localized: .self_report_share_result_privacy_box]
    }

    var bulletedListHeader: XCUIElement {
        app.staticTexts[localized: .self_report_share_result_bulleted_list_header]
    }

    var bulletedList: [XCUIElement] {
        app.staticTexts[localized: .self_report_share_result_bulleted_list]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .continue_button_label]
    }
}
