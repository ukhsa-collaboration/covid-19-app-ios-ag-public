//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import Localization
import Scenarios
import XCTest

class StraplineComponentTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<StraplineComponentScenario>

    func testBasics() throws {
        try runner.run { app in
            let strapline = StraplineComponent(app: app)
            XCTAssert(strapline.englishAccessbilityLabel.exists)
            XCTAssert(strapline.welshAccessbilityLabel.exists)
            XCTAssertNotEqual(strapline.englishAccessbilityLabel, strapline.welshAccessbilityLabel)
        }
    }

}

struct StraplineComponent {
    var app: XCUIApplication

    var englishAccessbilityLabel: XCUIElement {
        app.staticTexts[localized: .home_strapline_accessiblity_label]
    }

    var welshAccessbilityLabel: XCUIElement {
        app.staticTexts[localized: .home_strapline_accessiblity_label]
    }
}
