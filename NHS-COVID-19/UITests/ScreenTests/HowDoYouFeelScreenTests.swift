//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class HowDoYouFeelScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<HowDoYouFeelScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = HowDoYouFeelScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.yesRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noRadioButton(selected: false).exists)
            XCTAssertTrue(screen.continueButton.exists)

            XCTAssertFalse(screen.error.exists)
            XCTAssertFalse(screen.yesRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noRadioButton(selected: true).exists)
        }
    }

    func testYesButton() throws {
        try runner.run { app in
            let screen = HowDoYouFeelScreen(app: app)
            screen.yesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.yesOptionAlertTitle].exists)
        }
    }
    func testNoButton() throws {
        try runner.run { app in
            let screen = HowDoYouFeelScreen(app: app)
            screen.noRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noOptionAlertTitle].exists)
        }
    }

    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = HowDoYouFeelScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.error.exists)
        }
    }

    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = HowDoYouFeelScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.error.exists)

            screen.yesRadioButton(selected: false).tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.error.exists)
        }
    }
}
