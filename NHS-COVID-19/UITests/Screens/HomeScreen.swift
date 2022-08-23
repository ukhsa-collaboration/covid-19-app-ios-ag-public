//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct HomeScreen {
    var app: XCUIApplication

    func riskLevelBanner(for postcode: String, title: String) -> XCUIElement {
        return app.buttons[verbatim: title.replacingOccurrences(of: "[postcode]", with: postcode).apply(direction: currentLanguageDirection())]
    }

    func localInfoBanner(text: String) -> XCUIElement {
        app.buttons.element(containing: text)
    }

    var selfDiagnosisButton: XCUIElement {
        app.buttons[localized: .home_diagnosis_button_title]
    }

    var settingsButton: XCUIElement {
        app.buttons[localized: .home_settings_button_title]
    }

    var checkInButton: XCUIElement {
        app.buttons[localized: .home_checkin_button_title]
    }

    var aboutButton: XCUIElement {
        app.buttons[localized: .home_about_the_app_button_title]
    }

    func isolatingIndicatorWarning(date: Date, days: Int) -> XCUIElement {
        app.staticTexts[localized: .isolation_indicator_accessiblity_label(date: date, days: days)]
    }

    func isolatingIndicatorInformational(date: Date, days: Int) -> XCUIElement {
        app.staticTexts[localized: .be_careful_indicator_accessibility_label(date: date, days: days)]
    }

    var notIsolatingIndicator: XCUIElement {
        app.staticTexts[localized: .risk_level_indicator_contact_tracing_active]
    }

    var disabledContactTracing: XCUIElement {
        app.staticTexts[localized: .risk_level_indicator_contact_tracing_not_active]
    }

    var turnContactTracingBackOnButton: XCUIElement {
        app.buttons[localized: .risk_level_indicator_contact_tracing_turn_back_on_button]
    }

    var enterTestResultButton: XCUIElement {
        app.buttons[localized: .home_link_test_result_button_title]
    }

    var contactTracingHubButton: XCUIElement {
        app.buttons[localized: .home_contact_tracing_hub_button_title]
    }

    var testingHubButton: XCUIElement {
        app.buttons[localized: .home_testing_hub_button_title]
    }

    var selfIsolationHubButton: XCUIElement {
        app.buttons[localized: .home_self_isolation_button_title]
    }

    var statsHubButton: XCUIElement {
        app.buttons[localized: .status_option_local_data]
    }

    var contactTracingDoesNotWorkWithBTOffLabel: XCUIElement {
        app.staticTexts[localized: .bluetooth_not_active]
    }

    var turnOnBluetoothButton: XCUIElement {
        app.buttons[localized: .bluetooth_activate]
    }

    func guidanceHubButton() -> XCUIElement {
            app.buttons.element(containing: localize(.home_covid19_guidance_button_title))
    }
}
