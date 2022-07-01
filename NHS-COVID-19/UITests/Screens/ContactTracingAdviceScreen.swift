//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct ContactTracingAdviceScreen {
    let app: XCUIApplication

    var heading: XCUIElement {
        return app.staticTexts[localized: .contact_tracing_should_not_pause_heading]
    }

    var bulletItems: [XCUIElement] {
        return localizeAndSplit(.contact_tracing_should_not_pause_bullet_points)
            .map { app.staticTexts.element(containing: $0) }
    }

    var footnote: XCUIElement {
        return app.staticTexts[localized: .contact_tracing_should_not_pause_footnote]
    }
}
