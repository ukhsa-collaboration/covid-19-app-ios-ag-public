//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class PlodTestResultFlowTests: XCTestCase {
    
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
        $runner.initialState.testResult = "plod"
    }
    
    func testWithoutIsolation() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Plod Test Result", "Without Isolation") {
            """
            User opens the app after receiving a plod test result while not currently being in isolation
            """
        }
        try runner.run { app in
            
            runner.step("Plod Test Result") {
                """
                The user is presented with a screen containing information on their plod test result while not being
                in isolation.
                The user can acknowledge the test by tapping "back to home" button
                """
            }
            let plodTestResultScreen = PlodTestResultScreen(app: app)
            
            XCTAssertTrue(plodTestResultScreen.description.allExist)
            
            plodTestResultScreen.primaryButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
    func testWithIsolationIndexCase() throws {
        $runner.report(scenario: "Plod Test Result", "With Isolation") {
            """
            User opens the app after receiving a plod test result while currently being in isolation
            """
        }
        try runner.run { app in
            
            runner.step("Plod Test Result") {
                """
                The user is presented with a screen containing information on their plod test result while being
                in isolation.
                The user can acknowledge the test by tapping "back to home" button
                """
            }
            let plodTestResultScreen = PlodTestResultScreen(app: app)
            
            XCTAssertTrue(plodTestResultScreen.description.allExist)
            
            plodTestResultScreen.primaryButton.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen
                """
            }
            
            app.checkOnHomeScreen(postcode: postcode)
            
        }
    }
    
}
