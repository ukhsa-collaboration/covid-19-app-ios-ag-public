//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class SymptomsCheckerFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.enable(\.$guidanceHubEnglandToggle)
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
    }
        
    func testEnglandSymptomCheckerTryStayAtHomePath() throws {
        $runner.report(scenario: "Symptoms Checker", "Try stay at home path") {
            """
            User selects symptoms and gets advice to try to stay at home.
            """
        }
        
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Report symptoms.'
                """
            }
            
            homeScreen.selfDiagnosisButton.tap()
            
            runner.step("Symptoms questions") {
                """
                The user is presented with two questions about cardinal and non cardinal symptoms.
                """
            }
            
            let symptomsListScreen = YourSymptomsScreen(app: app)
            
            symptomsListScreen.firstYesRadioButton(selected: false).tap()
            symptomsListScreen.secondYesRadioButton(selected: false).tap()
            
            runner.step("Symptoms Questions Answered") {
                """
                The user answers yes to both having cardinal and non cardinal symptoms.
                """
            }
            
            app.scrollTo(element: symptomsListScreen.reportButton)
            symptomsListScreen.reportButton.tap()
            
            runner.step("How do you feel question") {
                """
                The user is presented with a question about feeling well enough to go to work or do normal activities.
                """
            }
            
            let howDoYouFeelScreen = HowDoYouFeelScreen(app: app)
            
            app.scrollTo(element: howDoYouFeelScreen.noRadioButton(selected: false))
            howDoYouFeelScreen.noRadioButton(selected: false).tap()
            
            runner.step("How do you feel answered") {
                """
                The user answers no to the question about feeling well enough to go to work or do normal activities.
                """
            }
            
            app.scrollTo(element: howDoYouFeelScreen.continueButton)
            howDoYouFeelScreen.continueButton.tap()
            
            runner.step("Check your answers") {
                """
                The user is presented with a summary of the answers for review.
                """
            }
            
            let checkYourAnswers = CheckYourAnswersScreen(app: app)
            
            app.scrollTo(element: checkYourAnswers.submitButton)
            checkYourAnswers.submitButton.tap()
            
            runner.step("Try to stay at home") {
                """
                The user is asked to try to stay at home
                """
            }
            
            let tryToStayHomeScreen = SymptomaticCaseSummaryTryStayHomeScreen(app: app)
            tryToStayHomeScreen.backToHomeButton.tap()

            runner.step("Home screen (via Back to home button)") {
                """
                The user is returned to the Home screen.
                """
            }
        }
    }
    
    func testEnglandSymptomCheckerContinueWithNormalActivitiesPath() throws {
        $runner.report(scenario: "Symptoms Checker", "Continue with normal activities path") {
            """
            User selects symptoms and gets advice.
            """
        }
        
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            app.checkOnHomeScreenNotIsolating()
            
            runner.step("Home Screen") {
                """
                When the user is on the Home screen they can tap 'Report symptoms.'
                """
            }
            
            homeScreen.selfDiagnosisButton.tap()
            
            runner.step("Symptoms questions") {
                """
                The user is presented with two questions about cardinal and non cardinal symptoms.
                """
            }
            
            let symptomsListScreen = YourSymptomsScreen(app: app)
            
            symptomsListScreen.firstNoRadioButton(selected: false).tap()
            symptomsListScreen.secondNoRadioButton(selected: false).tap()
            
            runner.step("Symptoms Questions Answered") {
                """
                The user answers no to having cardinal and non cardinal symptoms.
                """
            }
            
            symptomsListScreen.reportButton.tap()
            
            runner.step("How do you feel question") {
                """
                The user is presented with a question about feeling well enough to go to work or do normal activities.
                """
            }
            
            let howDoYouFeelScreen = HowDoYouFeelScreen(app: app)
            
            howDoYouFeelScreen.yesRadioButton(selected: false).tap()
            
            runner.step("How do you feel answered") {
                """
                The user answers yes to the question about feeling well enough to go to work or do normal activities.
                """
            }
            
            howDoYouFeelScreen.continueButton.tap()
            
            runner.step("Check your answers") {
                """
                The user is presented with a summary of the answers for review.
                """
            }
            
            let checkYourAnswers = CheckYourAnswersScreen(app: app)
            checkYourAnswers.submitButton.tap()
            
            runner.step("Normal activities") {
                """
                The user is adviced to continue with normal activities
                """
            }
            
            let normalActivitiesScreen = SymptomaticCaseBackToNormalActivitiesScreen(app: app)
            normalActivitiesScreen.backToHomeButton.tap()

            runner.step("Home screen (via Back to home button)") {
                """
                The user is returned to the Home screen.
                """
            }
        }
    }
}
