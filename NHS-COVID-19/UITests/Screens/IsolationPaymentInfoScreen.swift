//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct IsolationPaymentInfoScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .isolation_payment_info_title]
    }

    var heading: XCUIElement {
        app.staticTexts[localized: .isolation_payment_info_header]
    }

    var description: XCUIElement {
        app.staticTexts[localized: .isolation_payment_info_description]
    }

    var button: XCUIElement {
        app.links[localized: .isolation_payment_info_button]
    }
}
