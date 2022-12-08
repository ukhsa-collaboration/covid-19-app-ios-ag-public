//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingTestTypeScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingTestTypeScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.positiveRadioButton(selected: false).exists)
            XCTAssertTrue(screen.negativeRadioButton(selected: false).exists)
            XCTAssertTrue(screen.voidRadioButton(selected: false).exists)
            XCTAssertTrue(screen.continueButton.exists)

            XCTAssertFalse(screen.errorBox.exists)
            XCTAssertFalse(screen.errorDescription.exists)
            XCTAssertFalse(screen.positiveRadioButton(selected: true).exists)
            XCTAssertFalse(screen.negativeRadioButton(selected: true).exists)
            XCTAssertFalse(screen.voidRadioButton(selected: true).exists)
        }
    }

    func testPositiveButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            screen.positiveRadioButton(selected: false).tap()
            XCTAssertTrue(screen.positiveRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.positiveTestSelected].exists)
        }
    }

    func testNegativeButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            screen.negativeRadioButton(selected: false).tap()
            XCTAssertTrue(screen.negativeRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.negativeTestSelected].exists)
        }
    }

    func testVoidButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            screen.voidRadioButton(selected: false).tap()
            XCTAssertTrue(screen.voidRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.voidTestSelected].exists)
        }
    }

    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)
        }
    }

    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestTypeScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)

            screen.positiveRadioButton(selected: false).tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.errorBox.exists)
        }
    }
}
