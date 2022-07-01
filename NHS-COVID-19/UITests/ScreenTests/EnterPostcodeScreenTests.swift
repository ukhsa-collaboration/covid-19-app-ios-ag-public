//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class EnterPostcodeScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<EnterPostcodeScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)

            XCTAssert(screen.stepTitle.exists)
            XCTAssert(screen.exampleLabel.exists)
            XCTAssert(screen.postcodeTextField.exists)
            XCTAssert(screen.informationTitle.exists)
            XCTAssert(screen.informationDescription1.exists)
            XCTAssert(screen.informationDescription2.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }

    func testKeyboardDoesntAppearOverTextField() throws {
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)
            screen.postcodeTextField.tap()

            // Add small delay to wait for views' frame update after keyboard appears
            sleep(1)

            XCTAssertTrue(screen.postcodeTextField.isHittable)
        }
    }

    func testEnteringPostcodeWithContinueButton() throws {
        $runner.report("Happy path") {
            """
            Enter a valid postcode.
            """
        }
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)

            let postcode = runner.scenario.Postcodes.valid.rawValue

            XCTAssert(screen.stepTitle.exists)

            runner.step("Start") {
                """
                The user is asked to enter their postcode.
                """
            }

            screen.postcodeTextField.tap()
            screen.postcodeTextField.typeText(postcode)

            if runner.isGeneratingReport {
                // TODO: Can we improve this?
                // The scrolling of text field into view is still animated. Wait for it to finish
                usleep(300_000)
            }

            runner.step("Enter postcode") {
                """
                After entering the postcode, the user can continue.
                The screen must scroll so the text field is fully in view.
                """
            }

            screen.continueButton.tap()

            XCTAssert(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
            XCTAssert(app.staticTexts[postcode].exists)

            runner.step("Confirm") {
                """
                The postcode will be stored for later use.
                """
            }
        }
    }

    func testEnteringPostcodeByPressingEnter() throws {
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)

            let postcode = runner.scenario.Postcodes.valid.rawValue

            screen.postcodeTextField.tap()
            screen.postcodeTextField.typeText("\(postcode)\n")

            XCTAssert(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
            XCTAssert(app.staticTexts[postcode].exists)
        }
    }

    func testDraggingDismissesKeyboard() throws {
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)

            let postcode = runner.scenario.Postcodes.valid.rawValue

            screen.postcodeTextField.tap()
            screen.postcodeTextField.typeText(postcode)
            screen.stepTitle.swipeUp()

            XCTAssertFalse(screen.postcodeTextField.hasKeyboardFocus)
        }
    }

    func testEnteringInvalidPostcodeShowsAnError() throws {
        try runner.run { app in
            let screen = EnterPostcodeScreen(app: app)

            let postcode = runner.scenario.Postcodes.invalid.rawValue

            screen.postcodeTextField.tap()
            screen.postcodeTextField.typeText("\(postcode)\n")

            XCTAssert(screen.errorTitle.exists)
            XCTAssert(app.staticTexts[runner.scenario.errorDescription].exists)
        }
    }

}
