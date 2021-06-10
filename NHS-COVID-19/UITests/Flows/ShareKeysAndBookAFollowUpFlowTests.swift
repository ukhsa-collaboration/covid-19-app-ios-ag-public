//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class ShareKeysAndBookAFollowUpFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUpWithError() throws {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = "SW1A"
        $runner.initialState.localAuthorityId = "E09000022"
    }
    
    func testCombinedShareKeysAndBookAFollowUpTestFlow() throws {
        
        // Set up
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.initialState.testResult = "positive"
        $runner.initialState.supportsKeySubmission = true
        $runner.initialState.requiresConfirmatoryTest = true
        $runner.initialState.testKitType = "RAPID_RESULT"
        
        try $runner.initialState.set(testResultEndDate: LocalDay.today.advanced(by: -2).startOfDay)
        
        $runner.report(scenario: "Share Keys And Book A Follow Up Test", "Combined Flow") {
            """
            Someone gets a positive lateral flow test result that allows them to BOTH:
            * share their keys
            * book a confirmatory PCR test
            """
        }
        try runner.run { app in
            
            runner.step("Isolation screen") {
                """
                We see the positive test result screen, telling the person they need to isolate
                """
            }
            
            let positiveScreen = PositiveTestResultContinueIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            positiveScreen.continueButton.tap()
            
            runner.step("Share random IDs") {
                """
                The person is invited to share their device's random IDs (keys)
                and taps continue.
                """
            }
            
            let shareKeysScreen = ShareKeysScreen(app: app)
            XCTAssertTrue(shareKeysScreen.heading.exists)
            shareKeysScreen.continueButton.tap()
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Thank you screen") {
                """
                On the thank you screen, the button is labelled 'continue.'
                """
            }
            
            let thankYouScreen = ThankYouScreen(app: app)
            thankYouScreen.continueButtonText.tap()
            
            runner.step("Book a Follow Up Test Screen") {
                """
                The person sees a screen inviting them to book a follow-up test,
                because they got their positive result from a rapid swab test
                rather than a confirmed PCR test. Tapping the primary button
                goes to the test booking flow.
                """
            }
            let bookAFollowUpTestScreen = BookAFollowUpTestScreen(app: app)
            XCTAssertTrue(bookAFollowUpTestScreen.heading.exists)
            bookAFollowUpTestScreen.primaryButton.tap()
            
            runner.step("Book a Test Screen") {
                """
                The usual test-booking screen is displayed.
                """
            }
            let bookATestScreen = BookATestScreen(app: app)
            XCTAssertTrue(bookATestScreen.description.allExist)
            bookATestScreen.cancelButton.tap()
            
            runner.step("Home Screen") {
                """
                Cancelling the Book a Test screen returns to the home screen.
                """
            }
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.testingHubButton.exists)
        }
    }
    
    func testDoesNotInviteToBookFollowUpTestOnEnteringUnconfirmedAfterConfirmed() throws {
        
        func setupInitialState() {
            $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
            $runner.initialState.testResult = "positive"
            $runner.initialState.supportsKeySubmission = true
            $runner.initialState.requiresConfirmatoryTest = false
            $runner.initialState.testKitType = "LAB_RESULT"
        }
        
        setupInitialState()
        try $runner.initialState.set(testResultEndDate: LocalDay.today.advanced(by: -2).startOfDay)
        
        $runner.report(
            scenario: "Share Keys And Book A Follow Up Test",
            "Entering unconfirmed test result AFTER confirmed test result"
        ) {
            """
            Someone gets an unconfirmed positive test AFTER a confirmed positive
            test. They should be invited to share their keys, but they shouldn't
            be invited to book a follow-up test.
            """
        }
        try runner.run { app in
            
            runner.step("Positive test result screen") {
                """
                We see the positive test result screen, telling the person they need to isolate
                """
            }
            
            let positiveScreen = PositiveTestResultContinueIsolationScreen(app: app)
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            positiveScreen.continueButton.tap()
            
            runner.step("Share random IDs") {
                """
                The person is invited to share their device's random IDs (keys)
                and taps continue.
                """
            }
            
            let shareKeysScreen = ShareKeysScreen(app: app)
            XCTAssertTrue(shareKeysScreen.heading.exists)
            shareKeysScreen.continueButton.tap()
            
            let alertScreen = SimulatedShareRandomIdsScreen(app: app)
            alertScreen.shareButton.tap()
            
            runner.step("Thank you screen") {
                """
                On the thank you screen, the button is labelled 'back to home.'
                """
            }
            
            let thankYouScreen = ThankYouScreen(app: app)
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Home screen") {
                """
                We return to the home screen.
                """
            }
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.testingHubButton.exists)
            
            $runner.initialState.testResult = "positive"
            $runner.initialState.supportsKeySubmission = true
            $runner.initialState.requiresConfirmatoryTest = true
            $runner.initialState.testKitType = "RAPID_RESULT"
            
            app.scrollTo(element: homeScreen.enterTestResultButton)
            homeScreen.enterTestResultButton.tap()
            
            runner.step("Enter Test Result Screen") {
                """
                The person returns to the link test result screen to enter their
                unconfirmed test result
                """
            }
            
            let enterTestResultScreen = LinkTestResultScreen(app: app)
            enterTestResultScreen.testCodeTextField.tap()
            enterTestResultScreen.testCodeTextField.typeText("testendd")
            enterTestResultScreen.continueButton.tap()
            
            runner.step("Isolation screen - second test result") {
                """
                The person sees the isolation screen once again
                """
            }
            XCTAssertTrue(positiveScreen.indicationLabel.exists)
            positiveScreen.continueButton.tap()
            
            runner.step("Share Keys screen - second test result") {
                """
                The person is invited to share their keys again
                """
            }
            XCTAssertTrue(shareKeysScreen.heading.exists)
            shareKeysScreen.continueButton.tap()
            alertScreen.shareButton.tap()
            
            runner.step("Thank You screen - second test result") {
                """
                The person sees the Thank You screen with the 'back home' button
                """
            }
            XCTAssertTrue(thankYouScreen.headingText.exists)
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Home screen - after second test result") {
                """
                The person returns to the home screen WITHOUT seeing being
                invited to book a follow-up test
                """
            }
            XCTAssertTrue(homeScreen.testingHubButton.exists)
            
            // reset state
            setupInitialState()
        }
        
    }
}
