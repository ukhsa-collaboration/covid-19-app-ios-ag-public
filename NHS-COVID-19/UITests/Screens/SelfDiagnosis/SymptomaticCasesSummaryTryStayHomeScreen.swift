//
// Copyright © 2022 DHSC. All rights reserved.
//
//

import Localization
import Scenarios
import XCTest
import Interface

struct SymptomaticCaseSummaryTryStayHomeScreen {
    let app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_stay_at_home_header]
    }

    var yourAdiceInfoBox: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_notice_header]
    }

    var yourAdiceInforText1: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_notice_body_one]
    }

    var yourAdviceLink: XCUIElement {
        app.links[localized: .symptom_checker_advice_notice_stay_at_home_link_text]
    }

    var testSymptomaticCase: XCUIElement {
        app.staticTexts[SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapSymptomaticCase]
    }

    var yourAdiceInforText2: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_notice_body_two]
    }

    var testOnlineServiceLink: XCUIElement {
        app.staticTexts[SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapOnlineServicesLink]
    }

    var onlineServicesLink: XCUIElement {
        app.links[localized: .nhs_111_online_service]
    }

    var whenToseekMedicalAdviceHeader: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_icon_header]
    }

    var nhsInfoSubHeader: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_bulleted_paragraph_header]
    }

    func worriedAboutYourSymptomsBullets() -> XCUIElement {
        // MARK: Bullet points are split so we take only short prefix to detect the text on that screen
        app.staticTexts.element(containing: String(localize(.symptom_checker_advice_bulleted_paragraph_body).prefix(7)))
    }

    var infoEmergencyText: XCUIElement {
        app.staticTexts[localized: .symptom_checker_advice_emergency_contact_body]
    }

    var backToHomeButton: XCUIElement {
        app.buttons[localized: .summary_page_go_home]
    }

    var testBackToHomeButton: XCUIElement {
        app.staticTexts[SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapReturnHome]
    }
}

