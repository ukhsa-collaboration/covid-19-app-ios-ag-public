//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class SymptomsReviewScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SymptomsReviewViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            
            XCTAssert(screen.stepsLabel.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.confirmHeading.exists)
            XCTAssert(screen.denyHeading.exists)
            XCTAssert(screen.dateHeading.exists)
            XCTAssert(screen.noDate.exists)
            XCTAssert(screen.confirmButton.exists)
        }
    }
    
    func testConfirmSymptoms() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            screen.noDate.tap()
            screen.confirmButton.tap()
            XCTAssert(screen.confirmAlertText.exists)
        }
    }
    
    func testChangeSymptoms() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            screen.changeButton.tap()
            XCTAssert(screen.changeAlertText.exists)
        }
    }
}
