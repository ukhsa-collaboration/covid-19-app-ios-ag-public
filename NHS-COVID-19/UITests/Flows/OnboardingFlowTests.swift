//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class OnboardingFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    func testHappyPathFreshInstallToHomeScreen() throws {
        $runner.report(scenario: "Onboarding", "Happy path") {
            """
            Enter a valid postcode and activation code, provide all permissions, and reach home screen.
            """
        }
        
        try runner.run { app in
            let startScreen = StartOnboardingScreen(app: app)
            XCTAssert(startScreen.stepTitle.exists)
            
            runner.step("Onboarding") {
                """
                The user is presented a screen with information on what this app can do.
                The user continues.
                """
            }
            
            startScreen.continueButton.tap()
            
            runner.step("Onboarding") {
                """
                The user is asked to confirm they are above a minimum age requirement.
                The user indicates they are old enough to use the app.
                """
            }
            
            XCTAssert(startScreen.ageConfirmationAcceptButton.exists)
            startScreen.ageConfirmationAcceptButton.tap()
            
            let privacyScreen = PrivacyScreen(app: app)
            XCTAssert(privacyScreen.title.exists)
            
            runner.step("Privacy") {
                """
                The user is presented with our privacy policy and information about how we protect their data.
                """
            }
            
            app.scrollTo(element: privacyScreen.agreeButton)
            
            runner.step("Privacy") {
                """
                The user is asked to agree to our terms of use before continuing.
                The user agrees.
                """
            }
            
            privacyScreen.agreeButton.tap()
            
            let postcodeScreen = EnterPostcodeScreen(app: app)
            XCTAssert(postcodeScreen.stepTitle.exists)
            
            runner.step("Postcode Entry Screen") {
                """
                The user is asked to enter their postcode.
                """
            }
            
            postcodeScreen.postcodeTextField.tap()
            postcodeScreen.postcodeTextField.typeText("CE1B")
            
            if runner.isGeneratingReport {
                #warning("Can we improve this?")
                // The scrolling of text field into view is still animated. Wait for it to finish
                usleep(300_000)
            }
            
            runner.step("Postcode Entry Screen - Enter postcode") {
                """
                The user types in their postcode, then continues.
                """
            }
            
            postcodeScreen.continueButton.tap()
            
            let permissionsScreen = PermissionsScreen(app: app)
            XCTAssert(permissionsScreen.stepTitle.exists)
            
            runner.step("Permissions") {
                """
                The user is presented with information on which permissions are necessary for the app before we ask for authorization.
                The user continues.
                """
            }
            
            permissionsScreen.continueButton.tap()
            
            let simulatedENAuthorizationScreen = SimulatedENAuthorizationScreen(app: app)
            
            runner.step("Permissions - Exposure Notification") {
                """
                The user is asked for permission to enable Exposure Notifications
                The user allows.
                """
            }
            
            simulatedENAuthorizationScreen.allowButton.tap()
            
            let simulatedUserNotificationAuthorizationScreen = SimulatedUserNotificationAuthorizationScreen(app: app)
            
            runner.step("Permissions - User Notification") {
                """
                The user is asked for permission to enable User Notifications
                The user allows.
                """
            }
            
            simulatedUserNotificationAuthorizationScreen.allowButton.tap()
            
            runner.step("Home Screen") {
                """
                The user is presented the Home screen.
                """
            }
            
            let homeScreen = HomeScreen(app: app)
            XCTAssert(homeScreen.notIsolatingIndicator.exists)
        }
    }
    
}
