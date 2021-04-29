//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest

class LinkPositiveTestResultFlowTests: XCTestCase {
    
    private let postcode = "SW12"
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUpWithError() throws {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
    }
    
    func testAskForSymptomsOnsetDayDidNotHaveSymptoms() throws {
        $runner.report(scenario: "Positive Test Result", "Without symptoms") {
            """
            User taps on enter test result button on home screen,
            User enters a confirmed postive test result code,
            User confirms he does not have symptoms,
            User confirms uploading keys, and go back to home screen.
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
            
            let testCheckSymptomsScreen = TestCheckSymptomsScreen(app: app)
            XCTAssert(testCheckSymptomsScreen.yesButton.exists)
            
            runner.step("Check Symptoms screen") {
                """
                The user is presented the check symptoms screen.
                The user taps on No button to proceed.
                """
            }
            
            testCheckSymptomsScreen.noButton.tap()
            
            let positiveScreen = PositiveTestResultStartIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            
            runner.step("Positive Test Result screen") {
                """
                The user is presented with a screen containing information on their positive test result and that their
                period of self-isloation is over.
                The user taps on continue button to proceed.
                """
            }
            
            positiveScreen.continueButton.tap()
            
            let shareScreen = ShareKeysScreen(app: app)
            XCTAssertTrue(shareScreen.heading.exists)
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue button to proceed.
                """
            }
            
            shareScreen.continueButton.tap()
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share button to proceed.
                """
            }
            
            let thankYouScreen = ThankYouScreen(app: app)
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Thank you screen") {
                """
                The user is presented the thank you message.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceTestResultEndDate).startDate(in: .current)
            app.checkOnHomeScreenIsolating(date: date, days: Sandbox.Config.Isolation.indexCaseSinceTestResultEndDate)
            
            runner.step("Homescreen") {
                """
                The user is presented the home screen again and is isolating.
                """
            }
        }
    }
    
    func testAskForSymptomsOnsetDayDidHaveSymptomsButDoesNotRememberOnsetDay() throws {
        $runner.report(scenario: "Positive Test Result", "With symptoms but no OnsetDay") {
            """
            User taps on enter test result button on home screen,
            User enters a confirmed postive test result code,
            User confirms he does have symptoms,
            User confirms he does not remember the symptoms onset day,
            User confirms uploading keys, and go back to home screen.
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
            
            homeScreen.enterTestResultButton.tap()
            
            let linkTestResultScreen = LinkTestResultScreen(app: app)
            XCTAssert(linkTestResultScreen.testCodeTextField.exists)
            
            runner.step("Enter Test Result screen") {
                """
                The user is presented the enter test result screen.
                The user enters the test code.
                The user taps on continue button to proceed.
                """
            }
            
            linkTestResultScreen.testCodeTextField.tap()
            linkTestResultScreen.testCodeTextField.typeText("testendd")
            linkTestResultScreen.continueButton.tap()
            
            let testCheckSymptomsScreen = TestCheckSymptomsScreen(app: app)
            XCTAssert(testCheckSymptomsScreen.yesButton.exists)
            
            runner.step("Check Symptoms screen") {
                """
                The user is presented the check symptoms screen.
                The user taps on Yes button to proceed.
                """
            }
            
            testCheckSymptomsScreen.yesButton.tap()
            
            let testSymptomsReviewScreen = TestSymptomsReviewScreen(app: app)
            XCTAssert(testSymptomsReviewScreen.noDate.exists)
            
            runner.step("Review Symptoms screen") {
                """
                The user is presented the review symptoms screen.
                The user taps on the checkbox I do not remember the date.
                The user taps on continue button the proceed.
                """
            }
            
            testSymptomsReviewScreen.noDate.tap()
            testSymptomsReviewScreen.continueButton.tap()
            
            let positiveScreen = PositiveTestResultStartIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            
            runner.step("Positive Test Result screen") {
                """
                The user is presented with a screen containing information on their positive test result and that their
                period of self-isloation is over.
                The user taps on continue button to proceed.
                """
            }
            
            positiveScreen.continueButton.tap()
            
            let shareScreen = ShareKeysScreen(app: app)
            XCTAssertTrue(shareScreen.heading.exists)
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue button to proceed.
                """
            }
            
            shareScreen.continueButton.tap()
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share button to proceed.
                """
            }
            
            let thankYouScreen = ThankYouScreen(app: app)
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Thank you screen") {
                """
                The user is presented the thank you message.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceTestResultEndDate).startDate(in: .current)
            app.checkOnHomeScreenIsolating(date: date, days: Sandbox.Config.Isolation.indexCaseSinceTestResultEndDate)
            
            runner.step("Homescreen") {
                """
                The user is presented the home screen again and is isolating.
                """
            }
        }
    }
    
    func testAskForSymptomsOnsetDayDidHaveSymptomsAndDoesRememberOnsetDay() throws {
        $runner.report(scenario: "Positive Test Result", "With symptoms and OnsetDay") {
            """
            User taps on the enter test result button on home screen,
            User enters a confirmed postive test result code,
            User confirms he does have symptoms,
            User enters the symptoms onsetDay,
            User confirms uploading keys, and go back to home screen.
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
            
            homeScreen.enterTestResultButton.tap()
            
            let linkTestResultScreen = LinkTestResultScreen(app: app)
            XCTAssert(linkTestResultScreen.testCodeTextField.exists)
            
            runner.step("Enter Test Result screen") {
                """
                The user is presented the enter test result screen.
                The user enter the test code.
                """
            }
            
            linkTestResultScreen.testCodeTextField.tap()
            linkTestResultScreen.testCodeTextField.typeText("testendd")
            linkTestResultScreen.continueButton.tap()
            
            let testCheckSymptomsScreen = TestCheckSymptomsScreen(app: app)
            XCTAssert(testCheckSymptomsScreen.yesButton.exists)
            
            runner.step("Check Symptoms screen") {
                """
                The user is presented the check symptoms screen.
                The user taps on Yes button to proceed.
                """
            }
            
            testCheckSymptomsScreen.yesButton.tap()
            
            let testSymptomsReviewScreen = TestSymptomsReviewScreen(app: app)
            XCTAssert(testSymptomsReviewScreen.noDate.exists)
            
            runner.step("Review Symptoms screen") {
                """
                The user is presented the review symptoms screen.
                The user taps on the text field to select a date from the presented picker.
                The user taps on continue button the proceed.
                """
            }
            
            testSymptomsReviewScreen.dateTextField.tap()
            testSymptomsReviewScreen.doneButton.tap()
            
            testSymptomsReviewScreen.continueButton.tap()
            
            let positiveScreen = PositiveTestResultStartIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            
            runner.step("Positive Test Result screen") {
                """
                The user is presented with a screen containing information on their positive test result and that their
                period of self-isloation is over.
                The user taps on continue button to proceed.
                """
            }
            
            positiveScreen.continueButton.tap()
            
            let shareScreen = ShareKeysScreen(app: app)
            XCTAssertTrue(shareScreen.heading.exists)
            
            runner.step("Share random ids") {
                """
                The user is presented with a modal screen telling them to share their device random ids.
                The user taps on continue button to proceed.
                """
            }
            
            shareScreen.continueButton.tap()
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Share random ids - System Alert") {
                """
                The user is asked by the system to confirm sharing the device random ids.
                The user taps on Share button to proceed.
                """
            }
            
            let thankYouScreen = ThankYouScreen(app: app)
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Thank you screen") {
                """
                The user is presented the thank you message.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisOnset).startDate(in: .current)
            app.checkOnHomeScreenIsolating(date: date, days: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisOnset)
            
            runner.step("Homescreen") {
                """
                The user is presented the home screen again and is isolating.
                """
            }
        }
        
    }
}
