//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingTestSupplierScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingTestSupplierScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingTestSupplierScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.bulletedListHeader.exists)
            XCTAssertTrue(screen.bulletedList.allExist)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.yesRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noRadioButton(selected: false).exists)
            XCTAssertTrue(screen.continueButton.exists)

            XCTAssertFalse(screen.errorBox.exists)
            XCTAssertFalse(screen.errorDescription.exists)
            XCTAssertFalse(screen.yesRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noRadioButton(selected: true).exists)
        }
    }

    func testYesRadioButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestSupplierScreen(app: app)
            screen.yesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.yesSelected].exists)
        }
    }

    func testNoRadioButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestSupplierScreen(app: app)
            screen.noRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noSelected].exists)
        }
    }

    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestSupplierScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)
        }
    }

    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestSupplierScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)

            screen.yesRadioButton(selected: false).tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.errorBox.exists)
        }
    }
}
