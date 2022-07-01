//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class WarnAndTestCheckSymptomsScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<WarnAndTestCheckSymptomsScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = WarnAndTestCheckSymptomsScreen(app: app)
            XCTAssertTrue(screen.titleLabel.exists)
            XCTAssertTrue(screen.headingLabel.exists)
            XCTAssertTrue(screen.descriptionLabel.allExist)
            XCTAssertTrue(screen.submitButton.exists)
            XCTAssertTrue(screen.cancelButton.exists)
        }
    }
}
