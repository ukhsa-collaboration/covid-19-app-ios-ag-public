//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class TestSymptomsReviewScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<TestSymptomsReviewScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = TestSymptomsReviewScreen(app: app)
            XCTAssertTrue(screen.headingLabel.exists)
            XCTAssertTrue(screen.descriptionLabel.allExist)
            XCTAssertTrue(screen.continueButton.exists)
            XCTAssertTrue(screen.noDate.exists)
        }
    }
    
    func testConfirmSymptoms() throws {
        try runner.run { app in
            let screen = TestSymptomsReviewScreen(app: app)
            screen.noDate.tap()
            screen.continueButton.tap()
            XCTAssertTrue(screen.confirmAlertText.exists)
        }
    }
    
}
