//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class BelowRequiredAgeErrorScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<BelowRequiredAgeErrorScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = BelowRequiredAgeErrorScreen(app: app)

            XCTAssert(screen.title.exists)
        }
    }
}
