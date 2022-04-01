//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class IsolationAdviceForSymptomaticCasesEnglandScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<IsolationAdviceForSymptomaticCasesEnglandViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = IsolationAdviceForSymptomaticCasesEnglandScreen(app: app)
            for element in screen.allElements {
                app.scrollTo(element: element)
                XCTAssertTrue(element.exists, "Could not found \(element)")
            }
        }
    }
    
    func testContinueButton() throws {
        try runner.run { app in
            let screen = IsolationAdviceForSymptomaticCasesEnglandScreen(app: app)
            screen.continueButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.continueButtonTapped].exists)
        }
    }
}
