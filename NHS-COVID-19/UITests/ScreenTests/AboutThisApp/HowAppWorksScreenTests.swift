//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class HowAppWorksScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<HowAppWorksScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = HowAppWorksScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.blueToothHeader.exists)
            XCTAssertTrue(screen.blueToothDesc.exists)
            XCTAssertTrue(screen.batteryHeader.exists)
            XCTAssertTrue(screen.batteryDesc.exists)
            XCTAssertTrue(screen.locationHeader.exists)
            XCTAssertTrue(screen.locationDesc.exists)
            XCTAssertTrue(screen.privacyHeader.exists)
            XCTAssertTrue(screen.privacyDesc.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testContinueButton() throws {
        try runner.run { app in
            let screen = HowAppWorksScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[HowAppWorksScreenScenario.continueButtonTapped].exists)
        }
    }
}
