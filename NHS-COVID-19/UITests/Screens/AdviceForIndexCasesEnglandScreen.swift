//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation
import Interface
import Scenarios
import XCTest

struct AdviceForIndexCasesEnglandScreen {

    let app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localized: .index_case_isolation_advice_heading_title]
    }

    var infoBox: XCUIElement {
        app.staticTexts[localized: .index_case_isolation_advice_information_box_description]
    }

    var body: XCUIElement {
        app.staticTexts[localized: .index_case_isolation_advice_body]
    }

    var commmonQuestionsLink: XCUIElement {
        app.links[localized: .index_case_isolation_advice_common_question_link_button]
    }

    var furtherAdvice: XCUIElement {
        app.staticTexts[localized: .index_case_isolation_advice_further_advice]
    }

    var nhsOnlineLink: XCUIElement {
        app.links[localized: .index_case_isolation_advice_nhs_onilne_link_button]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .index_case_isolation_advice_primary_button_title]
    }
}
