//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class YourSymptomsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<YourSymptomsViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            XCTAssertFalse(screen.firstQuestionNotAnswerdError.exists)
            XCTAssertFalse(screen.secondQuestionNotAnswerdError.exists)
            XCTAssertFalse(screen.noQuestionsAnswerdError.exists)
            
            XCTAssertTrue(screen.stepsLabel.exists)
            
            XCTAssertTrue(screen.nonCardinalSymptomsHeading.exists)
            XCTAssertTrue(screen.nonCardinalSymptomsDescription.exists)
            XCTAssertTrue(screen.firstYesRadioButton(selected: false).exists)
            XCTAssertTrue(screen.firstNoRadioButton(selected: false).exists)
            
            XCTAssertTrue(screen.cardinalSymptomsHeading.exists)
            XCTAssertTrue(screen.secondYesRadioButton(selected: false).exists)
            XCTAssertTrue(screen.secondNoRadioButton(selected: false).exists)
            
            XCTAssertTrue(screen.reportButton.exists)
        }
    }

    func testRadioButtonsNoNo() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstNoRadioButton(selected: false).tap()
            app.scrollTo(element: screen.secondNoRadioButton(selected: false))
            screen.secondNoRadioButton(selected: false).tap()
            XCTAssertTrue(screen.firstNoRadioButton(selected: true).exists)
            XCTAssertTrue(screen.secondNoRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            screen.reportButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noNoOptionAlertTitle].exists)
        }
    }
    
    func testRadioButtonsNoYes() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstNoRadioButton(selected: false).tap()
            app.scrollTo(element: screen.secondYesRadioButton(selected: false))
            screen.secondYesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.firstNoRadioButton(selected: true).exists)
            XCTAssertTrue(screen.secondYesRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            screen.reportButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noYesOptionAlertTitle].exists)
        }
    }
    
    func testRadioButtonsYesNo() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstYesRadioButton(selected: false).tap()
            app.scrollTo(element: screen.secondNoRadioButton(selected: false))
            screen.secondNoRadioButton(selected: false).tap()
            XCTAssertTrue(screen.firstYesRadioButton(selected: true).exists)
            XCTAssertTrue(screen.secondNoRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            screen.reportButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.yesNoOptionAlertTitle].exists)
        }
    }
    
    func testRadioButtonsYesYes() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstYesRadioButton(selected: false).tap()
            app.scrollTo(element: screen.secondYesRadioButton(selected: false))
            screen.secondYesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.firstYesRadioButton(selected: true).exists)
            XCTAssertTrue(screen.secondYesRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            screen.reportButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.yesYesOptionAlertTitle].exists)
        }
    }
    
    
    
    func testNoQuestionsAnswerdErrorAppearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            XCTAssertTrue(screen.noQuestionsAnswerdError.exists)
        }
    }
    
    func testFirstQuestionNotAnswerdErrorAppearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            app.scrollTo(element: screen.secondYesRadioButton(selected: false))
            screen.secondYesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.secondYesRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            XCTAssertTrue(screen.firstQuestionNotAnswerdError.exists)
        }
    }
    
    func testSecondQuestionNotAnswerdErrorAppearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstYesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.firstYesRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            XCTAssertTrue(screen.secondQuestionNotAnswerdError.exists)
        }
    }

    func testNoQuestionsAnswerdErrorDisappearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            
            XCTAssertTrue(screen.noQuestionsAnswerdError.exists)

            screen.firstYesRadioButton(selected: false).tap()
            
            XCTAssertFalse(screen.noQuestionsAnswerdError.exists)
        }
    }
    
    func testFirstQuestionNotAnswerdErrorDisappearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            app.scrollTo(element: screen.secondYesRadioButton(selected: false))
            screen.secondYesRadioButton(selected: false).tap()
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            
            XCTAssertTrue(screen.firstQuestionNotAnswerdError.exists)

            app.scrollTo(element: screen.firstYesRadioButton(selected: false))
            screen.firstYesRadioButton(selected: false).tap()
            
            XCTAssertFalse(screen.firstQuestionNotAnswerdError.exists)
        }
    }
    
    func testSecondQuestionNotAnswerdErrorDisappearance() throws {
        try runner.run { app in
            let screen = YourSymptomsScreen(app: app)
            
            screen.firstYesRadioButton(selected: false).tap()
            
            app.scrollTo(element: screen.reportButton)
            XCTAssertTrue(screen.reportButton.isHittable)
            screen.reportButton.tap()
            
            XCTAssertTrue(screen.secondQuestionNotAnswerdError.exists)

            app.scrollTo(element: screen.secondYesRadioButton(selected: false))
            screen.secondYesRadioButton(selected: false).tap()
            
            XCTAssertFalse(screen.secondQuestionNotAnswerdError.exists)
        }
    }
}
