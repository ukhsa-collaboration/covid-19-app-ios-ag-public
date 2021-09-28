//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class ExposureNotificationFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    private let isolationDaysRemanining: Int = {
        let indexCaseSinceTestResultEndDate = Sandbox.Config.Isolation.indexCaseSinceTestResultEndDate
        let daysSinceReceivingExposureNotification = Sandbox.Config.Isolation.daysSinceReceivingExposureNotification
        return indexCaseSinceTestResultEndDate - daysSinceReceivingExposureNotification
    }()
    
    private static var exposureDate: Date {
        GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification).startDate(in: .current)
    }
    
    private static var daysSinceExposure: Int {
        -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification
    }
    
    private static var contactCaseIsolationDays: Int {
        Sandbox.Config.Isolation.contactCaseSinceExposureDay
    }
    
    private static var vaccineThresholdDate: Date {
        let exposureDay = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification)
        return exposureDay.advanced(by: -15).startDate(in: .current)
    }
    
    private static var birthThresholdDate: Date {
        let exposureDay = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification)
        return exposureDay.advanced(by: -183).startDate(in: .current)
    }
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019" // Sheffield
    }
    
    // MARK: - Currently user is not isolated
    
    func testReceiveExposureNotificationFullyVaccinated() throws {
        $runner.report(scenario: "Exposure Notification", "Fully Vaccinated") {
            """
            Currently user is not isolated
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are fully vaccinated
            User sees 'You do not need to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: false).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
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
            XCTAssertTrue(fullyVaccinatedScreen.allElements.allExist)
            
            runner.step("Fully Vaccinated screen") {
                """
                The person sees the 'You do not need to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: fullyVaccinatedScreen.backToHomeButton)
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
    
    func testReceiveExposureNotificationNotFullyVaccinated() throws {
        $runner.report(scenario: "Exposure Notification", "Not Fully Vaccinated") {
            """
            Currently user is not isolated
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are not fully vaccinated
            User sees 'You are advised to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: false).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
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
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).exists)
            
            runner.step("Vaccination Status screen - First question") {
                """
                The person sees the first question
                The person selected "No" on the first question
                """
            }
            
            vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Second question") {
                """
                The person selected "No" on the first question and sees the second question
                """
            }
            
            app.scrollTo(element: vaccinationStatusScreen.noMedicallyExemptRadioButton(selected: false))
            vaccinationStatusScreen.noMedicallyExemptRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noMedicallyExemptRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Third question") {
                """
                The person selected "No" on the second question and sees the third question
                """
            }
            
            vaccinationStatusScreen.noClinicalTrialRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noClinicalTrialRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Confirm") {
                """
                The person selected "No" on the third question.
                They tap the 'Confirm' button.
                """
            }
            
            XCTAssertTrue(vaccinationStatusScreen.confirmButton.exists)
            vaccinationStatusScreen.confirmButton.tap()
            
            // Advice to self-isolate
            let startIsolationScreen = ContactCaseStartIsolationScreen(
                app: app,
                isolationPeriod: Self.contactCaseIsolationDays,
                daysSinceEncounter: Self.daysSinceExposure,
                remainingDays: isolationDaysRemanining
            )
            XCTAssertTrue(startIsolationScreen.backToHomeButton.exists)
            
            runner.step("Advice to self-isolate screen") {
                """
                The person sees the 'You are adviced to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            startIsolationScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is isolating.
                """
            }
            
            let endDate = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.contactCaseSinceExposureDay).startDate(in: .current)
            
            app.checkOnHomeScreenIsolating(date: endDate, days: Sandbox.Config.Isolation.contactCaseSinceExposureDay)
        }
    }
    
    func testReceiveExposureNotificationMedicallyExempt() throws {
        $runner.report(scenario: "Exposure Notification", "Medically Exempt") {
            """
            Currently user is not isolated
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are not fully vaccinated
            User declares that they are medically exempt
            User sees 'You do not need to self-isolate (medically exempt)' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: false).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
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
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).exists)
            
            runner.step("Vaccination Status screen - First question") {
                """
                The person sees the first question
                """
            }
            
            vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Second question") {
                """
                The person selected "No" on the first question and sees the second question
                """
            }
            
            vaccinationStatusScreen.yesMedicallyExemptRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.yesMedicallyExemptRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Confirm") {
                """
                The person selected "No" on the second question.
                They tap the 'Confirm' button.
                """
            }
            
            XCTAssertTrue(vaccinationStatusScreen.confirmButton.exists)
            vaccinationStatusScreen.confirmButton.tap()
            
            // Advice to self-isolate
            let medicallyExemptScreen = ContactCaseNoIsolationMedicallyExemptScreen(app: app)
            XCTAssertTrue(medicallyExemptScreen.backToHomeButton.exists)
            
            runner.step("Medically Exempt screen") {
                """
                The person sees the 'You do not need to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: medicallyExemptScreen.backToHomeButton)
            medicallyExemptScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is isolating.
                """
            }
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
    
    func testReceiveExposureNotificationUnderAgeLimit() throws {
        $runner.report(scenario: "Exposure Notification", "Under Age Limit") {
            """
            Currently user is not isolated
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are under age limit
            User sees 'You do not need to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: false).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
            XCTAssertTrue(ageDeclarationScreen.noRadioButton(selected: false).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen.
                They select the 'No' button.
                """
            }
            
            ageDeclarationScreen.noRadioButton(selected: false).tap()
            XCTAssertTrue(ageDeclarationScreen.noRadioButton(selected: true).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen with the selected 'No' button.
                They tap the 'Continue' button.
                """
            }
            
            XCTAssertTrue(ageDeclarationScreen.continueButton.exists)
            ageDeclarationScreen.continueButton.tap()
            
            // Under Age Limit
            let underAgeLimitScreen = ContactCaseNoIsolationUnderAgeLimitScreen(app: app)
            XCTAssertTrue(underAgeLimitScreen.allElements.allExist)
            XCTAssertTrue(underAgeLimitScreen.backToHomeButton.exists)
            
            runner.step("Under Age Limit screen") {
                """
                The person sees the 'You do not need to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: underAgeLimitScreen.backToHomeButton)
            underAgeLimitScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is not Isolating.
                """
            }
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
    
    // MARK: - Currently user is already isolated as an index case
    
    func testReceiveExposureNotificationFullyVaccinatedWhenUserIsIsolatedAsAnIndexCase() throws {
        $runner.report(scenario: "Exposure Notification", "Fully Vaccinated - User is already isolated as an index case") {
            """
            Currently user is isolated as an index case
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are fully vaccinated
            User sees 'You are advised to continue to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.indexAndContact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: true).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
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
            
            // Continue Isolation screen
            let continueIsolationScreen = ContactCaseContinueIsolationScreen(app: app)
            XCTAssertTrue(continueIsolationScreen.daysRemanining(with: isolationDaysRemanining).exists)
            XCTAssertTrue(continueIsolationScreen.backToHomeButton.exists)
            
            runner.step("Continue Isolation screen") {
                """
                The person sees the 'You are advised to continue to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: continueIsolationScreen.backToHomeButton)
            continueIsolationScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is isolating.
                """
            }
            
            let endDate = GregorianDay.today.advanced(by: isolationDaysRemanining).startDate(in: .current)
            
            app.checkOnHomeScreenIsolating(date: endDate, days: isolationDaysRemanining)
        }
    }
    
    func testReceiveExposureNotificationNotFullyVaccinatedWhenUserIsIsolatedAsAnIndexCase() throws {
        $runner.report(scenario: "Exposure Notification", "Not Fully Vaccinated - User is already isolated as an index case") {
            """
            Currently user is isolated as an index case
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are over age limit
            User declares that they are not fully vaccinated
            User sees 'You are advised to continue to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.indexAndContact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: true).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
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
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).exists)
            
            runner.step("Vaccination Status screen - First question") {
                """
                The person sees the first question
                The person selected "No" on the first question
                """
            }
            
            vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Second question") {
                """
                The person selected "No" on the first question and sees the second question
                """
            }
            
            vaccinationStatusScreen.noMedicallyExemptRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noMedicallyExemptRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Third question") {
                """
                The person selected "No" on the second question and sees the third question
                """
            }
            
            vaccinationStatusScreen.noClinicalTrialRadioButton(selected: false).tap()
            XCTAssertTrue(vaccinationStatusScreen.noClinicalTrialRadioButton(selected: true).exists)
            
            runner.step("Vaccination Status screen - Confirm") {
                """
                The person selected "No" on the third question.
                They tap the 'Confirm' button.
                """
            }
            
            XCTAssertTrue(vaccinationStatusScreen.confirmButton.exists)
            vaccinationStatusScreen.confirmButton.tap()
            
            // Continue Isolation screen
            let continueIsolationScreen = ContactCaseContinueIsolationScreen(app: app)
            XCTAssertTrue(continueIsolationScreen.daysRemanining(with: Sandbox.Config.Isolation.contactCaseSinceExposureDay).exists)
            XCTAssertTrue(continueIsolationScreen.backToHomeButton.exists)
            
            runner.step("Continue Isolation screen") {
                """
                The person sees the 'You are advised to continue to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: continueIsolationScreen.backToHomeButton)
            continueIsolationScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is isolating.
                """
            }
            
            let endDate = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.contactCaseSinceExposureDay).startDate(in: .current)
            
            app.checkOnHomeScreenIsolating(date: endDate, days: Sandbox.Config.Isolation.contactCaseSinceExposureDay)
        }
    }
    
    func testReceiveExposureNotificationUnderAgeLimitWhenUserIsIsolatedAsAnIndexCase() throws {
        $runner.report(scenario: "Exposure Notification", "Under Age Limit - User is already isolated as an index case") {
            """
            Currently user is isolated as an index case
            User receives an exposure notification
            User acknowledges the notification
            User declares that they are under age limit
            User sees 'You are advised to continue to self-isolate' screen
            User reaches Home screen
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.indexAndContact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            // Exposure Info
            let contactCaseExposureInfoScreen = ContactCaseExposureInfoScreen(app: app, date: Self.exposureDate)
            XCTAssertTrue(contactCaseExposureInfoScreen.allElements(isIndexCase: true).allExist)
            XCTAssertTrue(contactCaseExposureInfoScreen.continueButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The person sees the Exposure Notification screen.
                They tap the 'Continue' button.
                """
            }
            
            contactCaseExposureInfoScreen.continueButton.tap()
            
            // Age Declaration
            let ageDeclarationScreen = AgeDeclarationScreen(app: app, birthThresholdDate: Self.birthThresholdDate)
            XCTAssertTrue(ageDeclarationScreen.noRadioButton(selected: false).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen.
                They select the 'No' button.
                """
            }
            
            ageDeclarationScreen.noRadioButton(selected: false).tap()
            XCTAssertTrue(ageDeclarationScreen.noRadioButton(selected: true).exists)
            
            runner.step("Age Declaration screen") {
                """
                The person sees the Age Declaration screen with the selected 'No' button.
                They tap the 'Continue' button.
                """
            }
            
            XCTAssertTrue(ageDeclarationScreen.continueButton.exists)
            ageDeclarationScreen.continueButton.tap()
            
            // Continue Isolation screen
            let continueIsolationScreen = ContactCaseContinueIsolationScreen(app: app)
            XCTAssertTrue(continueIsolationScreen.daysRemanining(with: isolationDaysRemanining).exists)
            XCTAssertTrue(continueIsolationScreen.backToHomeButton.exists)
            
            runner.step("Continue Isolation screen") {
                """
                The person sees the 'You are advised to continue to self-isolate' screen.
                They tap the 'Back to Home' button.
                """
            }
            
            app.scrollTo(element: continueIsolationScreen.backToHomeButton)
            continueIsolationScreen.backToHomeButton.tap()
            
            // Home Screen
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is isolating.
                """
            }
            
            let endDate = GregorianDay.today.advanced(by: isolationDaysRemanining).startDate(in: .current)
            
            app.checkOnHomeScreenIsolating(date: endDate, days: isolationDaysRemanining)
        }
    }
}
