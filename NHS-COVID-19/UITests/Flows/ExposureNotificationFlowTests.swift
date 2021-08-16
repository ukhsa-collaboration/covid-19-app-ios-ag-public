//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class ExposureNotificationFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    private static var vaccineThresholdDate: Date {
        let exposureDay = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification)
        return exposureDay.startDate(in: .current).advanced(by: -15 * 24 * 60 * 60)
    }
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019" // Sheffield
    }
    
    func testReceiveExposureNotificationFullyVaccinated() throws {
        $runner.initialState.postcode = "LL44"
        $runner.initialState.localAuthorityId = "W06000002"
        
        $runner.report(scenario: "Exposure Notification", "Fully Vaccinated") {
            """
            User receives an exposure notification,
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are fully vaccinated
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app)
            XCTAssertTrue(ageDeclarationScreen.yesRadioButton(selected: false).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen.
                They select the 'Yes' button.
                """
            }
            
            ageDeclarationScreen.yesRadioButton(selected: false).tap()
            XCTAssertTrue(ageDeclarationScreen.yesRadioButton(selected: true).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen with the selected 'Yes' button.
                They tap the 'Continue' button.
                """
            }
            
            XCTAssertTrue(ageDeclarationScreen.continueButton.exists)
            ageDeclarationScreen.continueButton.tap()
            
            // Vaccination Status
            let vaccinationStatusScreen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: Self.vaccineThresholdDate)
            XCTAssertTrue(vaccinationStatusScreen.yesFullyVaccinatedRadioButton(selected: false).exists)
            
            runner.step("Vaccination Status screen") {
                """
                The person sees the Vaccination Status screen.
                They select the 'Yes, I've had all doses' button.
                """
            }
            
            vaccinationStatusScreen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.yesFullyVaccinatedRadioButton(selected: true).exists)
            app.scrollTo(element: vaccinationStatusScreen.yesLastDoseDateRadioButton(selected: false))
            XCTAssertTrue(vaccinationStatusScreen.yesLastDoseDateRadioButton(selected: false).exists)
            
            runner.step("Vaccination Status screen") {
                """
                The person sees the Vaccination Status screen with the selected 'Yes' button.
                They select the 'Yes, I received my last dose on or before the date' button.
                """
            }
            
            vaccinationStatusScreen.yesLastDoseDateRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.yesLastDoseDateRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen") {
                """
                The person sees the Vaccination Status screen with two selected 'Yes' buttons.
                They tap the 'Confirm' button.
                """
            }
            
            XCTAssertTrue(vaccinationStatusScreen.confirmButton.exists)
            vaccinationStatusScreen.confirmButton.tap()
            
            // Fully Vaccinated
            let fullyVaccinatedScreen = ContactCaseNoIsolationFullyVaccinatedScreen(app: app)
            XCTAssertTrue(fullyVaccinatedScreen.backToHomeButton.exists)
            
            runner.step("Fully Vaccinated screen") {
                """
                The person sees the Fully Vaccinated screen.
                They tap the 'Back to Home' button.
                """
            }
            
            fullyVaccinatedScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is not Isolating.
                """
            }
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
}
