//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceHubEnglandScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<GuidanceHubEnglandScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)

            XCTAssertTrue(screen.linkButtonOneEngland.exists)
            XCTAssertTrue(screen.linkButtonTwoEngland.exists)
            XCTAssertTrue(screen.linkButtonThreeEngland.exists)
            XCTAssertTrue(screen.linkButtonFourEngland.exists)
            XCTAssertTrue(screen.linkButtonFiveEngland.exists)
            XCTAssertTrue(screen.linkButtonSixEngland.exists)
            XCTAssertTrue(screen.linkButtonSevenEngland.exists)
            XCTAssertTrue(screen.linkButtonEightEngland.exists)
        }
    }

    func testEnglandButtonOne() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonOneEngland)
            screen.linkButtonOneEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link1EnglandTapped].exists)
        }
    }

    func testEnglandButtonTwo() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonTwoEngland)
            screen.linkButtonTwoEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link2EnglandTapped].exists)
        }
    }

    func testEnglandButtonThree() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonThreeEngland)
            screen.linkButtonThreeEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link3EnglandTapped].exists)
        }
    }

    func testEnglandButtonFour() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonFourEngland)
            screen.linkButtonFourEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link4EnglandTapped].exists)
        }
    }

    func testEnglandButtonFive() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonFiveEngland)
            screen.linkButtonFiveEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link5EnglandTapped].exists)
        }
    }

    func testEnglandButtonSix() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonSixEngland)
            screen.linkButtonSixEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link6EnglandTapped].exists)
        }
    }

    func testEnglandButtonSeven() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonSevenEngland)
            screen.linkButtonSevenEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link7EnglandTapped].exists)
        }
    }

    func testEnglandButtonEight() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.linkButtonEightEngland)
            screen.linkButtonEightEngland.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.link8EnglandTapped].exists)
        }
    }
}
