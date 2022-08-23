//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceHubWalesScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<GuidanceHubWalesScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)

            XCTAssertTrue(screen.linkButtonOneWales.exists)
            XCTAssertTrue(screen.linkButtonTwoWales.exists)
            XCTAssertTrue(screen.linkButtonThreeWales.exists)
            XCTAssertTrue(screen.linkButtonFourWales.exists)
            XCTAssertTrue(screen.linkButtonFiveWales.exists)
            XCTAssertTrue(screen.linkButtonSixWales.exists)
            XCTAssertTrue(screen.linkButtonSevenWales.exists)
            XCTAssertTrue(screen.linkButtonEightWales.exists)
        }
    }

    func testWalesButtonOne() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonOneWales)
            screen.linkButtonOneWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link1WalesTapped].exists)
        }
    }

    func testWalesButtonTwo() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonTwoWales)
            screen.linkButtonTwoWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link2WalesTapped].exists)
        }
    }

    func testWalesButtonThree() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonThreeWales)
            screen.linkButtonThreeWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link3WalesTapped].exists)
        }
    }

    func testWalesButtonFour() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonFourWales)
            screen.linkButtonFourWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link4WalesTapped].exists)
        }
    }

    func testWalesButtonFive() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonFiveWales)
            screen.linkButtonFiveWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link5WalesTapped].exists)
        }
    }

    func testWalesButtonSix() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonSixWales)
            screen.linkButtonSixWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link6WalesTapped].exists)
        }
    }

    func testWalesButtonSeven() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonSevenWales)
            screen.linkButtonSevenWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link7WalesTapped].exists)
        }
    }

    func testWalesButtonEight() throws {
        try runner.run { app in
            let screen = GuidanceHubWalesScreen(app: app)
            app.scrollTo(element: screen.linkButtonEightWales)
            screen.linkButtonEightWales.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link8WalesTapped].exists)
        }
    }
}
