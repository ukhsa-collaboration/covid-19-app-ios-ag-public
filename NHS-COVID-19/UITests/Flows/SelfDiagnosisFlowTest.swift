//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class NewSelfDiagnosisFlowTest: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    func testPositiveSymptomsPath() throws {
        
        $runner.report(scenario: "Self Diagnosis", "Positive symptoms path") {
            """
            User selects symptoms and is notified of corona symptoms
            """
        }
        
        $runner.initialState.isPilotActivated = true
        
        try runner.run { app in
            let startOnboardingScreen = StartOnboardingScreen(app: app)
            
            XCTAssert(startOnboardingScreen.stepTitle.exists)
        }
    }
}

class SelfDiagnosisFlowTest: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SelfDiagnosisFlowScenario>
    
    func testPositiveSymptomsPath() throws {
        $runner.report("Positive symptoms path") {
            """
            User selects symptoms and is notified of corona symptoms
            """
        }
        try runner.run { app in
            let symptomListScreen = SymptomsListScreen(app: app)
            XCTAssert(symptomListScreen.heading.exists)
            
            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }
            
            app.buttons[localized: .symptom_card_accessibility_label(heading: SelfDiagnosisFlowScenario.symptomCardHeading, content: SelfDiagnosisFlowScenario.symptomCardContent)].tap()
            
            runner.step("Symptom selected") {
                """
                The user selects a symptom and confirms the screen
                """
            }
            
            symptomListScreen.reportButton.tap()
            
            let reviewSymptomsScreen = SymptomsReviewScreen(app: app)
            XCTAssert(reviewSymptomsScreen.heading.exists)
            
            runner.step("Review Symptoms") {
                """
                The user is presented a list of the selected symptoms for review
                """
            }
            
            reviewSymptomsScreen.noDate.tap()
            reviewSymptomsScreen.confirmButton.tap()
            
            let positiveSymptomsScreen = PositiveSymptomsScreen(app: app)
            XCTAssert(positiveSymptomsScreen.indicationLabel.exists)
            
            runner.step("Positive Symptoms screen") {
                """
                The user is asked to isolate
                """
            }
        }
    }
    
    func testSymptomListInputValidation() throws {
        $runner.report("Symptom list input validation") {
            """
            User does not select a symptom before confirming the symptom list screen
            """
        }
        try runner.run { app in
            let symptomListScreen = SymptomsListScreen(app: app)
            XCTAssert(symptomListScreen.heading.exists)
            
            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }
            
            symptomListScreen.reportButton.tap()
            
            XCTAssert(symptomListScreen.errorBox.exists)
            
            runner.step("Symptom List Error") {
                """
                The user has selected no symptom
                """
            }
        }
    }
    
    func testReviewSymptomsInputValidation() throws {
        $runner.report("Review Symptoms Input Validation") {
            """
            User selects symptoms, but does not provide a start date or check the "I don't remember" control
            """
        }
        try runner.run { app in
            let symptomListScreen = SymptomsListScreen(app: app)
            XCTAssert(symptomListScreen.heading.exists)
            
            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }
            
            app.buttons[localized: .symptom_card_accessibility_label(heading: SelfDiagnosisFlowScenario.symptomCardHeading, content: SelfDiagnosisFlowScenario.symptomCardContent)].tap()
            
            runner.step("Symptom selected") {
                """
                The user selects a symptom and confirms the screen
                """
            }
            
            symptomListScreen.reportButton.tap()
            
            let reviewSymptomsScreen = SymptomsReviewScreen(app: app)
            XCTAssert(reviewSymptomsScreen.heading.exists)
            
            runner.step("Review Symptoms") {
                """
                The user is presented a list of the selected symptoms for review
                """
            }
            
            reviewSymptomsScreen.confirmButton.tap()
            
            XCTAssert(reviewSymptomsScreen.errorBox.exists)
            runner.step("Review Symptoms Input Validation Error") {
                """
                The user is presented an error informing about the invalid input
                """
            }
        }
    }
    
}
