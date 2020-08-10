//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class HomeFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<HomeFlowScenario>
    
    func testHappyPath() throws {
        $runner.report("Happy path") {
            """
            Users see the home screen
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            XCTAssert(homeScreen.riskLevelBanner.exists)
            
            runner.step("Diagnosis") {
                """
                Users can navigate to self diagnosis page
                """
            }
            homeScreen.diagnoisButton.tap()
            XCTAssert(app.staticTexts[HomeFlowScenario.showDiagnosisAlertTitle].displayed)
            
            app.buttons["Close"].tap()
            
            runner.step("Check-In") {
                """
                Users can navigate to checkin page
                """
            }
            homeScreen.checkInButton.tap()
            XCTAssert(app.staticTexts[HomeFlowScenario.showCheckInAlertTitle].displayed)
            
            app.buttons["Close"].tap()
            
            runner.step("Check-In") {
                """
                Users can navigate to advice page
                """
            }
            homeScreen.adviceButton.tap()
            XCTAssert(app.staticTexts[HomeFlowScenario.showAdviceAlertTitle].displayed)
            
            app.buttons["OK"].tap()
        }
    }
}
