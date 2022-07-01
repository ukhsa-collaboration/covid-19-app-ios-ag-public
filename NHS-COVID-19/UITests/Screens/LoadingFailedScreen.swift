//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct LoadingFailedScreen {
    var app: XCUIApplication

    var descriptionHeading: XCUIElement {
        app.staticTexts[localized: .loading_failed_heading]
    }

    var descriptionLabel: XCUIElement {
        app.staticTexts[localized: .loading_failed_body]
    }

    var retryButton: XCUIElement {
        app.buttons[localized: .loading_failed_action]
    }

    var retryButtonAlertTitle: XCUIElement {
        app.staticTexts[LoadingFailedScreenTemplateScenario.retryTapped]
    }
}
