//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class OnboardingFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    func testHappyPathFreshInstallToHomeScreenPostcodeAndSelectLocalAuthority() throws {
                
        $runner.report(scenario: "Onboarding", "Happy path - select local authority") {
            """
            Enter a valid postcode and select local authority to provide all permissions, and reach home screen.
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
            postcodeScreen.postcodeTextField.typeText("ST15")
            
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
            
            runner.step("Local authority screen") {
                """
                The user is asked to select a local authority.
                """
            }
            
            let localAuthorityScreen = SelectLocalAuthorityScreen(app: app)
            XCTAssert(localAuthorityScreen.linkBtn.exists)
            
            localAuthorityScreen.localAuthorityCard(checked: false, title: "Stafford").tap()
            
            runner.step("Local authority screen - select authority") {
                """
                The user selects their local authority, then continues.
                """
            }
            
            localAuthorityScreen.button.tap()
            
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
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
    
    func testHappyPathFreshInstallToHomeScreenPostcodeAndConfirmLocalAuthority() throws {
                
        $runner.report(scenario: "Onboarding", "Happy path - confirm local authority") {
            """
            Enter a valid postcode and confirm local authority to provide all permissions, and reach home screen.
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
            postcodeScreen.postcodeTextField.typeText("S1")
            
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
            
            runner.step("Local authority screen") {
                """
                The user is asked to select a local authority.
                """
            }
            
            let localAuthorityConfirmationScreen = LocalAuthorityConfirmationScreen(app: app)
            XCTAssert(localAuthorityConfirmationScreen.title.exists)
            
            localAuthorityConfirmationScreen.button.tap()
            
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
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
    
    func testPostcodeErrors() throws {
                
        $runner.report(scenario: "Onboarding", "Error Cases - Postcode") {
            """
            Enter an invalid or unsupported postcode
            """
        }
        
        try runner.run { app in
            let startScreen = StartOnboardingScreen(app: app)
            XCTAssert(startScreen.stepTitle.exists)
            
            startScreen.continueButton.tap()
            
            XCTAssert(startScreen.ageConfirmationAcceptButton.exists)
            startScreen.ageConfirmationAcceptButton.tap()
            
            let privacyScreen = PrivacyScreen(app: app)
            XCTAssert(privacyScreen.title.exists)
            
            app.scrollTo(element: privacyScreen.agreeButton)
            
            privacyScreen.agreeButton.tap()
            
            let postcodeScreen = EnterPostcodeScreen(app: app)
            XCTAssert(postcodeScreen.stepTitle.exists)
            
            runner.step("Postcode Entry Screen") {
                """
                The user is asked to enter their postcode.
                """
            }
            
            postcodeScreen.postcodeTextField.tap()
            if runner.isGeneratingReport {
                #warning("Can we improve this?")
                // The scrolling of text field into view is still animated. Wait for it to finish
                usleep(300_000)
            }
            
            postcodeScreen.continueButton.tap()
            XCTAssert(postcodeScreen.errorTitle.exists)
            
            runner.step("Postcode Entry Screen - Invalid Postcode") {
                """
                The user tries to continue without adding a postcode
                """
            }
            
            postcodeScreen.postcodeTextField.tap()
            postcodeScreen.postcodeTextField.typeText("DG1")
            
            postcodeScreen.continueButton.tap()
            
            runner.step("Postcode Entry Screen - Unsupported Country") {
                """
                The user types in their postcode that belongs to an unsupported country, then continues.
                """
            }
        }
    }
    
    func testLocalAuthorityErrors() throws {
                
        $runner.report(scenario: "Onboarding", "Error Cases - Local Authority") {
            """
            Enter a valid postcode and select invalid or unsupported local authority.
            """
        }
        
        try runner.run { app in
            let startScreen = StartOnboardingScreen(app: app)
            XCTAssert(startScreen.stepTitle.exists)
            
            startScreen.continueButton.tap()
            
            XCTAssert(startScreen.ageConfirmationAcceptButton.exists)
            startScreen.ageConfirmationAcceptButton.tap()
            
            let privacyScreen = PrivacyScreen(app: app)
            XCTAssert(privacyScreen.title.exists)
            
            app.scrollTo(element: privacyScreen.agreeButton)
            
            privacyScreen.agreeButton.tap()
            
            let postcodeScreen = EnterPostcodeScreen(app: app)
            XCTAssert(postcodeScreen.stepTitle.exists)
            
            postcodeScreen.postcodeTextField.tap()
            postcodeScreen.postcodeTextField.typeText("DG16")
            
            postcodeScreen.continueButton.tap()
            
            runner.step("Local authority screen") {
                """
                The user is asked to select a local authority.
                """
            }
            
            let localAuthorityScreen = SelectLocalAuthorityScreen(app: app)
            XCTAssert(localAuthorityScreen.linkBtn.exists)
            
            let card = localAuthorityScreen.localAuthorityCard(checked: false, title: "Scottish Borders")
            
            app.scrollTo(element: card)
            
            localAuthorityScreen.button.tap()
            
            XCTAssert(localAuthorityScreen.noSelectionError.exists)
            
            runner.step("Local authority screen - No local authority selected") {
                """
                The user did not select a local authority and tries to continue
                """
            }
            
            app.scrollTo(element: card)
            card.tap()
            
            localAuthorityScreen.button.tap()
            
            XCTAssert(localAuthorityScreen.unsupportedCountryError.exists)
            
            runner.step("Local authority screen - Invalid local authority selected") {
                """
                The user did select a local authority that belongs to an unsupported country, then tries to continue.
                """
            }
            
        }
    }
    
}
