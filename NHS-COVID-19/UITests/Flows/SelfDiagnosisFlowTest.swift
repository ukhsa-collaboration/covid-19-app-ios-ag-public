//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class SelfDiagnosisFlowTest: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
    }
    
    func testPositiveSymptomsPath() throws {
        
        $runner.report(scenario: "Self Diagnosis", "Positive symptoms path") {
            """
            User selects symptoms and is notified of corona symptoms
            """
        }
        
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Report symptoms'
                """
            }
            
            homeScreen.diagnoisButton.tap()
            
            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }
            
            let symptomsListScreen = SymptomsListScreen(app: app)
            
            symptomsListScreen.symptomCard(
                value: localize(.symptom_card_unchecked),
                heading: Sandbox.Text.SymptomsList.cardHeading.rawValue.apply(direction: currentLanguageDirection()),
                content: Sandbox.Text.SymptomsList.cardContent.rawValue.apply(direction: currentLanguageDirection())
            ).tap()
            
            runner.step("Symptom selected") {
                """
                The user selects a symptom and confirms the screen
                """
            }
            
            symptomsListScreen.reportButton.tap()
            
            let reviewSymptomsScreen = SymptomsReviewScreen(app: app)
            XCTAssert(reviewSymptomsScreen.heading.exists)
            
            runner.step("Review Symptoms") {
                """
                The user is presented a list of the selected symptoms for review
                """
            }
            
            reviewSymptomsScreen.noDate.tap()
            
            runner.step("No Date") {
                """
                The can specify an onset date or tick that they don't remember the onset date, before confirming
                """
            }
            
            reviewSymptomsScreen.confirmButton.tap()
            
            let positiveSymptomsScreen = PositiveSymptomsScreen(app: app)
            XCTAssert(positiveSymptomsScreen.indicationLabel.exists)
            
            runner.step("Positive Symptoms screen") {
                """
                The user is asked to isolate, and given the option to book a test
                """
            }
            positiveSymptomsScreen.bookTestButton.firstMatch.tap()
            
            let bookATestScreen = BookATestScreen(app: app)
            XCTAssert(bookATestScreen.title.exists)
            
            runner.step("Positive Symptoms screen") {
                """
                The user is presented with information about booking a test
                """
            }
            
            bookATestScreen.button.tap()
            
            runner.step("Positive Symptoms screen") {
                """
                The user is returned to the homescreen, which presents their isolation countdown and different menu options.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset).startDate(in: .current)
            
            app.checkOnHomeScreenIsolating(date: date, days: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset)
        }
    }
}
