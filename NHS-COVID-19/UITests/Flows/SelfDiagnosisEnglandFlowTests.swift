//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class SelfDiagnosisEnglandFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
    }
        
    func testEnglandPositiveSymptomsPath() throws {
        $runner.report(scenario: "Self Diagnosis England", "Positive symptoms path") {
            """
            User selects symptoms and is notified of COVID-19 symptoms
            """
        }
        
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            runner.step("Home Screen - clear") {
                """
                When the user is on the Home screen they can tap 'Report symptoms.'
                """
            }
            
            homeScreen.selfDiagnosisButton.tap()
            
            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }
            
            let symptomsListScreen = SymptomsListScreen(app: app)
            
            symptomsListScreen.symptomCard(
                value: localize(.symptom_card_unchecked, applyCurrentLanguageDirection: false),
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
            
            let isolationAdviceForSymptomaticCasesEnglandScreen = IsolationAdviceForSymptomaticCasesEnglandScreen(app: app)
            XCTAssert(isolationAdviceForSymptomaticCasesEnglandScreen.heading.exists)
            
            runner.step("Isolation Advice screen for symptomatic cases England") {
                """
                The user in England is adviced to isolate, and given the option to continue to the guidance screen
                """
            }
            isolationAdviceForSymptomaticCasesEnglandScreen.continueButton.tap()
            
            let guidanceForSymptomaticCasesEnglandScreen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            XCTAssert(guidanceForSymptomaticCasesEnglandScreen.heading.exists)
            
            runner.step("Guidance screen for symptomatic cases England") {
                """
                The user in England is presented the latest COVID-19 guidance screen with an option to go back to home screen
                """
            }
            app.scrollTo(element: guidanceForSymptomaticCasesEnglandScreen.backToHomeButton)
            guidanceForSymptomaticCasesEnglandScreen.backToHomeButton.tap()
            
            runner.step("Home Screen - 'please be careful'") {
                """
                The user is returned to the Home screen, which shows the 'informational' risk level indicator and different menu options.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset).startDate(in: .current)
            
            app.checkOnHomeScreenIsolatingInformational(date: date, days: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset)
        }
    }
}
