//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct HowAppWorksScreen {
    let app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_title]
    }

    var blueToothHeader: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_bluetooth_bullet_header]
    }

    var blueToothDesc: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_bluetooth_bullet_desc]
    }

    var batteryHeader: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_battery_bullet_header]
    }

    var batteryDesc: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_battery_bullet_desc]
    }

    var locationHeader: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_location_bullet_header]
    }

    var locationDesc: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_location_bullet_desc]
    }

    var privacyHeader: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_privacy_bullet_header]
    }

    var privacyDesc: XCUIElement {
        app.staticTexts[localized: .onboarding_how_app_works_privacy_bullet_desc]
    }

    var continueButton: XCUIElement {
        app.buttons[localized: .onboarding_how_app_works_continue]
    }

}
