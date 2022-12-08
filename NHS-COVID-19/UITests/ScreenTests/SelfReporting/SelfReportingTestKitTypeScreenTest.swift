//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingTestKitTypeScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingTestKitTypeScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingTestKitTypeScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.lfdRadioButton(selected: false).exists)
            XCTAssertTrue(screen.pcrRadioButton(selected: false).exists)
            XCTAssertTrue(screen.continueButton.exists)

            XCTAssertFalse(screen.errorBox.exists)
            XCTAssertFalse(screen.errorDescription.exists)
            XCTAssertFalse(screen.lfdRadioButton(selected: true).exists)
            XCTAssertFalse(screen.pcrRadioButton(selected: true).exists)
        }
    }

    func testLFDButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestKitTypeScreen(app: app)
            screen.lfdRadioButton(selected: false).tap()
            XCTAssertTrue(screen.lfdRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.lfdTestSelected].exists)
        }
    }

    func testPCRButton() throws {
        try runner.run { app in
            let screen = SelfReportingTestKitTypeScreen(app: app)
            screen.pcrRadioButton(selected: false).tap()
            XCTAssertTrue(screen.pcrRadioButton(selected: true).exists)

            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.pcrTestSelected].exists)
        }
    }

    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestKitTypeScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)
        }
    }

    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestKitTypeScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)

            screen.lfdRadioButton(selected: false).tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.errorBox.exists)
        }
    }
}
