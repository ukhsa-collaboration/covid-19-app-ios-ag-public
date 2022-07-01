//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LanguageSelectionScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<LanguageSelectionScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = LanguageSelectionScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.systemLanguageHeader.exists)
            XCTAssertTrue(screen.customLanguageHeader.exists)
        }
    }
}
