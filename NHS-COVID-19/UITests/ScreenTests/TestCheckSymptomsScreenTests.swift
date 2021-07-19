//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class TestCheckSymptomsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<TestCheckSymptomsScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = TestCheckSymptomsScreen(app: app)
            XCTAssertTrue(screen.titleLabel.exists)
            XCTAssertTrue(screen.headingLabel.exists)
            XCTAssertTrue(screen.descriptionLabel.allExist)
            XCTAssertTrue(screen.yesButton.exists)
            XCTAssertTrue(screen.noButton.exists)
        }
    }
}
