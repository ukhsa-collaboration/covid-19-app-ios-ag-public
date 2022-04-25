//
// Copyright © 2022 DHSC. All rights reserved.
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
        try $runner.initialState.set(testResultEndDate: LocalDay.today.advanced(by: -1).startOfDay)
    }
    
    func testCombinedShareKeysAndBookAFollowUpTestFlowEngland() throws {
        
        // Set up
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.initialState.testResult = "positive"
        $runner.initialState.supportsKeySubmission = true
        $runner.initialState.requiresConfirmatoryTest = true
        $runner.initialState.testKitType = "RAPID_RESULT"
        
        $runner.report(scenario: "Share Keys And Book A Follow Up Test", "Combined Flow") {
            """
            Someone gets a positive lateral flow test result that allows them to BOTH:
            * share their keys
            * book a confirmatory PCR test
            """
        }
        $runner.enable(\.$testingForCOVID19Toggle)
        
        try runner.run { app in
            
            runner.step("Advice for index cases screen in England") {
                """
                We see the advice screen.
                """
            }
            
            let adviceScreen = AdviceForIndexCasesEnglandAlreadyIsolatingScreen(app: app)
            XCTAssertTrue(adviceScreen.heading.exists)
            adviceScreen.continueButton.tap()
            
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
    
    func testCombinedShareKeysAndBookAFollowUpTestFlowWales() throws {
        
        // Set up
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.initialState.testResult = "positive"
        $runner.initialState.supportsKeySubmission = true
        $runner.initialState.requiresConfirmatoryTest = true
        $runner.initialState.testKitType = "RAPID_RESULT"
        $runner.initialState.localAuthorityId = "W06000023"
        $runner.enable(\.$testingForCOVID19Toggle)
        
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
    
    func testDoesNotInviteToBookFollowUpTestOnEnteringUnconfirmedAfterConfirmedInEngland() throws {
        $runner.initialState.testResult = "positive"
        $runner.initialState.supportsKeySubmission = true
        $runner.initialState.requiresConfirmatoryTest = true
        $runner.initialState.testKitType = "RAPID_RESULT"
        $runner.initialState.isolationCase = "indexWithPositiveTest"
        $runner.enable(\.$testingForCOVID19Toggle)

        
        $runner.report(
            scenario: "Share Keys And Book A Follow Up Test",
            "Entering unconfirmed test result AFTER confirmed test result in England"
        ) {
            """
            User gets an unconfirmed positive test AFTER a confirmed positive
            test. They should be invited to share their keys, but they shouldn't
            be invited to book a follow-up test.
            """
        }
        try runner.run { app in
            runner.step("Isolation screen") {
                """
                We see the positive test result screen, telling the person they need to continue isolation
                """
            }
            let positiveScreen = AdviceForIndexCasesEnglandAlreadyIsolatingScreen(app: app)
            XCTAssertTrue(positiveScreen.heading.exists)
            XCTAssertTrue(positiveScreen.infoBox.exists)
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
            
            runner.step("Thank You screen") {
                """
                The person sees the Thank You screen with the option to go back to home
                """
            }
            let thankYouScreen = ThankYouScreen(app: app)
            XCTAssertTrue(thankYouScreen.headingText.waitForExistence(timeout: 0.1))
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Home screen - after second test result") {
                """
                The person returns to the home screen WITHOUT being
                invited to book a follow-up test
                """
            }
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.testingHubButton.exists)
        }
    }
    
    func testDoesNotInviteToBookFollowUpTestOnEnteringUnconfirmedAfterConfirmedInWales() throws {
        $runner.initialState.testResult = "positive"
        $runner.initialState.supportsKeySubmission = true
        $runner.initialState.requiresConfirmatoryTest = true
        $runner.initialState.testKitType = "RAPID_RESULT"
        $runner.initialState.isolationCase = "indexWithPositiveTest"
        $runner.enable(\.$testingForCOVID19Toggle)
        $runner.initialState.postcode = "LL64"
        $runner.initialState.localAuthorityId = "W06000001"

        
        $runner.report(
            scenario: "Share Keys And Book A Follow Up Test",
            "Entering unconfirmed test result AFTER confirmed test result in Wales"
        ) {
            """
            User gets an unconfirmed positive test AFTER a confirmed positive
            test. They should be invited to share their keys, but they shouldn't
            be invited to book a follow-up test.
            """
        }
        try runner.run { app in
            runner.step("Isolation screen") {
                """
                We see the positive test result screen, telling the person they need to continue isolation
                """
            }
            let positiveScreen = PositiveTestResultContinueIsolationAfterConfirmedScreen(app: app)
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
            
            runner.step("Thank You screen") {
                """
                The person sees the Thank You screen with the option to go back to home
                """
            }
            let thankYouScreen = ThankYouScreen(app: app)
            XCTAssertTrue(thankYouScreen.headingText.waitForExistence(timeout: 0.1))
            thankYouScreen.backHomeButtonText.tap()
            
            runner.step("Home screen - after second test result") {
                """
                The person returns to the home screen WITHOUT being
                invited to book a follow-up test
                """
            }
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.testingHubButton.exists)
        }
    }

}
