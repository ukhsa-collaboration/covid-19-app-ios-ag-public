//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LinkTestResultScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LinkTestResultScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.header.exists)
            XCTAssert(screen.description.exists)
            XCTAssert(screen.subheading.exists)
            XCTAssert(screen.exampleLabel.exists)
            XCTAssert(screen.testCodeTextField.exists)
            XCTAssert(screen.cancelButton.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testEnteringTokenWithContinueButton() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            let code = runner.scenario.TestCodes.valid.rawValue
            
            XCTAssert(screen.header.exists)
            
            screen.testCodeTextField.tap()
            screen.testCodeTextField.typeText(code)
            
            screen.continueButton.tap()
            
            XCTAssert(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
            XCTAssert(app.staticTexts[code].exists)
            
        }
    }
    
    func testEnteringDelayedTokenWithContinueButton() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            let code = runner.scenario.TestCodes.delayed.rawValue.lowercased()
            
            XCTAssert(screen.header.exists)
            
            screen.testCodeTextField.tap()
            screen.testCodeTextField.typeText(code)
            
            screen.continueButton.tap()
            XCTAssertFalse(screen.continueButton.isEnabled)
            sleep(1)
            XCTAssertTrue(screen.continueButton.isEnabled)
            XCTAssert(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
            XCTAssert(app.staticTexts[code].exists)
            
        }
    }
    
    func testEnteringTokenByPressingEnter() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            let code = runner.scenario.TestCodes.valid.rawValue
            
            screen.testCodeTextField.tap()
            screen.testCodeTextField.typeText("\(code)\n")
            
            XCTAssert(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
            XCTAssert(app.staticTexts[code].exists)
        }
    }
    
    func testDraggingDismissesKeyboard() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            let code = runner.scenario.TestCodes.valid.rawValue
            
            screen.testCodeTextField.tap()
            screen.testCodeTextField.typeText(code)
            screen.header
                .press(forDuration: 0.1, thenDragTo: screen.testCodeTextField)
            
            XCTAssertFalse(screen.testCodeTextField.hasKeyboardFocus)
        }
    }
    
    func testEnteringInvalidCodeShowsAnError() throws {
        try runner.run { app in
            let screen = LinkTestResultScreen(app: app)
            
            let code = runner.scenario.TestCodes.invalid.rawValue
            
            screen.testCodeTextField.tap()
            screen.testCodeTextField.typeText("\(code)\n")
            
            XCTAssert(screen.scenarioError.exists)
        }
    }
    
}
