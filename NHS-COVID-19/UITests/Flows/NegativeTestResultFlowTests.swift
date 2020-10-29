//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class NegativeTestResultFlowTests: XCTestCase {
    
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.testResult = "negative"
    }
    
    func testWithoutIsolation() throws {
        $runner.report(scenario: "Negative Test Result", "Without Isolation") {
            """
            User opens the app after receiving a negative test result without currently being in isolation
            """
        }
        try runner.run { app in
            runner.step("Negative Test Result") {
                """
                The user is presented with a screen containing information on their negative test result.
                The user can return to the homescreen
                """
            }
            let negativeTestResultScreen = NegativeTestResultNoIsolationScreen(app: app)
            
            XCTAssertTrue(negativeTestResultScreen.description.exists)
            
            negativeTestResultScreen.returnHomeButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
    func testWithIsolationIndexCase() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Negative Test Result", "With Isolation - Index Case") {
            """
            User opens the app after receiving a negative test result with currently being in isolation as index case
            """
        }
        try runner.run { app in
            runner.step("Negative Test Result") {
                """
                The user is presented with a screen containing information on their negative test result and notified
                that they can finish self-isolation.
                The user can return to the homescreen
                """
            }
            let negativeTestResultScreen = NegativeTestResultNoIsolationScreen(app: app)
            
            XCTAssertTrue(negativeTestResultScreen.description.exists)
            
            negativeTestResultScreen.returnHomeButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is not isolating anymore
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
    func testWithIsolationContactCase() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.report(scenario: "Negative Test Result", "With Isolation - Contact Case") {
            """
            User opens the app after receiving a negative test result with currently being in isolation as contact case
            """
        }
        try runner.run { app in
            runner.step("Negative Test Result") {
                """
                The user is presented with a screen containing information on their negative test result and notified
                that they should continue to isolate.
                The user can return to the homescreen
                """
            }
            let negativeTestResultScreen = NegativeTestResultWithIsolationScreen(app: app)
            
            XCTAssertTrue(negativeTestResultScreen.continueToIsolateLabel.exists)
            
            negativeTestResultScreen.returnHomeButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is still isolating
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
        }
    }
}
