//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ClosureScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<ClosureScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)

            XCTAssert(screen.linkButtonFive.exists)
        }
    }

    func testButtonOne() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)
            app.scrollTo(element: screen.linkButtonOne)
            screen.linkButtonOne.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link1Tapped].exists)
        }
    }

    func testButtonTwo() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)
            app.scrollTo(element: screen.linkButtonTwo)
            screen.linkButtonTwo.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link2Tapped].exists)
        }
    }

    func testButtonThree() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)
            app.scrollTo(element: screen.linkButtonThree)
            screen.linkButtonThree.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link3Tapped].exists)
        }
    }

    func testButtonFour() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)
            app.scrollTo(element: screen.linkButtonFour)
            screen.linkButtonFour.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link4Tapped].exists)
        }
    }

    func testButtonFive() throws {
        try runner.run { app in
            let screen = ClosureScreen(app: app)
            app.scrollTo(element: screen.linkButtonFive)
            screen.linkButtonFive.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link5Tapped].exists)
        }
    }
}
