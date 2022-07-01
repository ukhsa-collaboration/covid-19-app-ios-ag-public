//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class HomeAnimationsScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<HomeAnimationsScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = HomeAnimationsScreen(app: app)

            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.description.exists)
            XCTAssert(screen.homeAnimationsToggleOnDescription.exists)
        }
    }

    func testToggleSwitch() throws {
        try runner.run { app in
            let screen = HomeAnimationsScreen(app: app)
            screen.homeAnimationsToggleOnDescription.tap()
            XCTAssert(screen.homeAnimationsToggleOffDescription.exists)
        }
    }
}
