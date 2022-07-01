//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class UnkownTestResultFlowTests: XCTestCase {

    private let postcode = "SW12"

    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
        $runner.initialState.testResult = "unknown"
    }

    func testUnknownTestResultUsingLinkTestResult() throws {

        $runner.report(scenario: "Unknown Test Result", "With link test result") {
            """
            User taps on enter test result button on home screen,
            User enters an unknown test result code,
            """
        }
        try runner.run { app in

            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.enterTestResultButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on enter test result button to proceed.
                """
            }

            app.scrollTo(element: homeScreen.enterTestResultButton)
            homeScreen.enterTestResultButton.tap()

            let linkTestResultScreen = LinkTestResultScreen(app: app)
            XCTAssert(linkTestResultScreen.testCodeTextField.exists)

            runner.step("Enter Test Result screen") {
                """
                The user is presented the enter test result screen.
                The user enters the test code
                The user taps on continue button to proceed.
                """
            }

            linkTestResultScreen.testCodeTextField.tap()
            linkTestResultScreen.testCodeTextField.typeText("testendd")
            linkTestResultScreen.continueButton.tap()

            runner.step("Unknown test result screen") {
                """
                The user is presented with the Unknown test result screen.
                The user taps on "Update in AppStore" button to proceed.
                """
            }

            let unknownTestResultScreen = UnknownTestResultsScreen(app: app)
            XCTAssertTrue(unknownTestResultScreen.openStoreButton.exists)
            unknownTestResultScreen.openStoreButton.tap()

            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.enterTestResultButton.waitForExistence(timeout: 0.1))

            runner.step("Home screen") {
                """
                The user is presented with a home screen and the isolation state hasn't been changed.
                """
            }

        }
    }
}
