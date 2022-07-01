//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Localization
import Scenarios
import XCTest

class BulletedListComponentTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<BulletPointComponentScenario>

    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.shortLabel.exists)
            XCTAssert(app.longLabel.exists)
        }
    }
}

private extension XCUIApplication {

    var shortLabel: XCUIElement {
        staticTexts[BulletPointComponentScenario.shortLabel]
    }

    var longLabel: XCUIElement {
        staticTexts[BulletPointComponentScenario.longLabel]
    }
}
