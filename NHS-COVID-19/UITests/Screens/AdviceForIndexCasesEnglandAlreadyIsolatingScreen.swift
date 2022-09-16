//

 // Copyright © 2022 DHSC. All rights reserved.
 //

import Foundation
import Interface
import Scenarios
import XCTest

struct AdviceForIndexCasesEnglandAlreadyIsolatingScreen {

    let app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localized: .index_case_already_isolating_advice_heading_title]
    }

    var infoBox: XCUIElement {
        app.staticTexts[localized: .index_case_already_isolating_advice_information_box_description]
    }

    var body: XCUIElement {
        app.staticTexts[localized: .index_case_already_isolating_advice_body]
    }

    var commmonQuestionsLink: XCUIElement {
        app.links[localized: .index_case_already_isolating_advice_common_question_link_button]
    }

    var furtherAdvice: XCUIElement {
        app.staticTexts[localized: .further_advice_header]
    }

    var nhsOnlineLink: XCUIElement {
        app.links[localized: .index_case_already_isolating_advice_nhs_onilne_link_button]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .index_case_already_isolating_advice_primary_button_title]
    }
}
