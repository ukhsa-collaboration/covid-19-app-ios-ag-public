//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class PositiveTestResultsFlowTest: XCTestCase {
    
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    let today = LocalDay.today
    
    override func setUpWithError() throws {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
        $runner.initialState.testResult = "positive"
        try $runner.initialState.set(testResultEndDate: today.advanced(by: -2).startOfDay)
    }
    
    func testWithoutIsolation() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.none.rawValue
        
        $runner.report(scenario: "Positive Test Result", "Without Isolation") {
            """
            User opens the app after receiving a positive test result without currently being in isolation
            """
        }
        try runner.run { app in
            runner.step("Positive Test Result") {
                """
                The user is presented with a screen containing information on their positive test result and that their
                period of self-isloation is over.
                The user taps on continue
                """
            }
            let positiveScreen = PositiveTestResultStartIsolationScreen(app: app)
            
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            
            positiveScreen.continueButton.tap()
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue
                """
            }
            
            let shareScreen = ShareKeysConfirmationScreen(app: app)
            
            XCTAssertTrue(shareScreen.heading.exists)
            
            #warning("Find out why it finds multiple elements with the accessibility label continue - it smells like a bug")
            shareScreen.app.buttons.element(boundBy: 1).tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share
                """
            }
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is not isolating.
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
    func testWithIsolationIndexCase() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Positive Test Result", "With Isolation - Index case") {
            """
            User opens the app after receiving a positive test result while currently being in isolation
            as an index case
            """
        }
        try runner.run { app in
            runner.step("Positive Test Result") {
                """
                The user is presented with a screen containing information on their positive test result and that they
                still should continue to self-isolate.
                The user taps on continue
                """
            }
            
            let positiveScreen = PositiveTestResultContinueIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            positiveScreen.continueButton.tap()
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue
                """
            }
            
            let shareScreen = ShareKeysConfirmationScreen(app: app)
            
            XCTAssertTrue(shareScreen.heading.exists)
            
            #warning("Find out why it finds multiple elements with the accessibility label continue - it smells like a bug")
            shareScreen.app.buttons.element(boundBy: 1).tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share
                """
            }
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is still isolating
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
    func testWithIsolationContactCase() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.report(scenario: "Positive Test Result", "With Isolation - contact case") {
            """
            User opens the app after receiving a positive test result while currently being in isolation
            as a contact case
            """
        }
        try runner.run { app in
            runner.step("Positive Test Result") {
                """
                The user is presented with a screen containing information on their positive test result and that they
                still should continue to self-isolate.
                The user taps on continue
                """
            }
            
            let positiveScreen = PositiveTestResultContinueIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            positiveScreen.continueButton.tap()
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue
                """
            }
            
            let shareScreen = ShareKeysConfirmationScreen(app: app)
            
            XCTAssertTrue(shareScreen.heading.exists)
            
            #warning("Find out why it finds multiple elements with the accessibility label continue - it smells like a bug")
            shareScreen.app.buttons.element(boundBy: 1).tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share
                """
            }
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is still isolating
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
        }
    }
    
}
