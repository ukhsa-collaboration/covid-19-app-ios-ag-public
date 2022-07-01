//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class BluetoothDisabledWarningScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<BluetoothDisabledWarningScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = BluetoothDisabledWarningScreen(app: app)

            XCTAssert(screen.heading.exists)
            XCTAssert(screen.infoBox.exists)
            XCTAssert(screen.description.allExist)
        }
    }

    func testPrimaryButton() throws {
        try runner.run { app in
            let screen = BluetoothDisabledWarningScreen(app: app)

            XCTAssert(screen.primaryButton.exists)

            screen.primaryButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.phoneSettingsButtonTapped].exists)
        }
    }

    func testSecondaryButton() throws {
        try runner.run { app in
            let screen = BluetoothDisabledWarningScreen(app: app)

            XCTAssert(screen.secondaryButton.exists)

            screen.secondaryButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.continueButtonTapped].exists)
        }
    }

}
