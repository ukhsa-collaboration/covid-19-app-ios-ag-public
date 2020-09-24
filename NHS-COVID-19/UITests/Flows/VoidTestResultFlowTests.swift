//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class VoidTestResultFlowTests: XCTestCase {
    
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.testResult = "void"
    }
    
    func testWithoutIsolation() throws {
        $runner.report(scenario: "Void Test Result", "Without Isolation") {
            """
            User opens the app after receiving a void test result while currently not being in isolation
            """
        }
        try runner.run { app in
            
            runner.step("Void Test Result") {
                """
                The user is presented with a screen containing information on their void test result while not being
                in isolation.
                The user can book a new test
                """
            }
            let voidTestResultScreen = VoidTestResultNoIsolationScreen(app: app)
            
            XCTAssertTrue(voidTestResultScreen.explanationLabel.exists)
            
            voidTestResultScreen.continueButton.tap()
            
            runner.step("Book a free test") {
                """
                The user is presented a screen with information on how to book a free test.
                After booking a test, they can go back to the app and are presented the homescreen
                """
            }
            
            let bookTestScreen = BookATestScreen(app: app)
            
            XCTAssertTrue(bookTestScreen.title.exists)
            
            bookTestScreen.button.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen
                """
            }
            
            let homeScreen = HomeScreen(app: app)
            
            XCTAssert(homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).exists)
            
        }
    }
    
    func testWithIsolationIndexCase() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Void Test Result", "With Isolation") {
            """
            User opens the app after receiving a void test result with currently being in isolation
            """
        }
        try runner.run { app in
            runner.step("Void Test Result") {
                """
                The user is presented with a screen containing information on their void test result and notified that
                they should continue to isolate
                The user can book a new test
                """
            }
            let voidTestResultScreen = VoidTestResultWithIsolationScreen(app: app)
            
            XCTAssertTrue(voidTestResultScreen.explanationLabel.exists)
            
            voidTestResultScreen.continueButton.tap()
            
            runner.step("Book a free test") {
                """
                The user is presented a screen with information on how to book a free test.
                After booking a test, they can go back to the app and are presented the homescreen
                """
            }
            
            let bookTestScreen = BookATestScreen(app: app)
            
            XCTAssertTrue(bookTestScreen.title.exists)
            
            bookTestScreen.button.tap()
            
            runner.step("Homescreen") {
                """
                The user is presented the homescreen and is still isolating
                """
            }
            
            let homeScreen = HomeScreen(app: app)
            
            XCTAssert(homeScreen.riskLevelBanner(for: postcode, risk: localize(.risk_level_low)).exists)
            
        }
    }
}
