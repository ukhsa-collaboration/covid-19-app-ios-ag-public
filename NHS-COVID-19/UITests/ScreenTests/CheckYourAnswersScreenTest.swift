//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class CheckYourAwnswersScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<CheckYourAnswersViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = CheckYourAnswersScreen(app: app)

            XCTAssertTrue(screen.stepsLabel.exists)
            XCTAssertTrue(screen.heading.exists)
            
            XCTAssertTrue(screen.firstCardHeading.exists)
            XCTAssertTrue(screen.firstChangeButton.exists)
            
            XCTAssertTrue(screen.nonCardinalSymptomsHeading.exists)
            XCTAssertTrue(screen.nonCardinalSymptomsDescription.exists)
            
            XCTAssertTrue(screen.cardinalSymptomsHeading.exists)
            
            XCTAssertTrue(screen.secondCardHeading.exists)
            XCTAssertTrue(screen.secondChangeButton.exists)
            XCTAssertTrue(screen.howYouFeelQuestion.exists)
          
            XCTAssertTrue(screen.submitButton.exists)
        }
    }

    func testFistChangeButton() throws {
        try runner.run { app in
            let screen = CheckYourAnswersScreen(app: app)

            app.scrollTo(element: screen.firstChangeButton)
            XCTAssertTrue(screen.firstChangeButton.isHittable)
            screen.firstChangeButton.tap()
            XCTAssertTrue(screen.changeButtonAlertText.exists)
        }
    }

    func testSecondChangeButton() throws {
        try runner.run { app in
            let screen = CheckYourAnswersScreen(app: app)

            app.scrollTo(element: screen.secondChangeButton)
            XCTAssertTrue(screen.secondChangeButton.isHittable)
            screen.secondChangeButton.tap()
            XCTAssertTrue(screen.changeButtonAlertText.exists)
        }
    }
    
    func testSubmitButton() throws {
        try runner.run { app in
            let screen = CheckYourAnswersScreen(app: app)
            
            app.scrollTo(element: screen.submitButton)
            XCTAssertTrue(screen.submitButton.isHittable)
            screen.submitButton.tap()
            XCTAssertTrue(screen.submitButtonAlertText.exists)
        }
    }
}
