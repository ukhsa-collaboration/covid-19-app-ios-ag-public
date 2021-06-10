//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SymptomAfterPositiveTestScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SymptomsAfterPositiveTestViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SymptomsAfterPositiveTestScreen(app: app)
            
            XCTAssert(screen.pleaseIsolateLabel.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.continueButton.exists)
            XCTAssert(screen.furtherAdviceLink.exists)
        }
    }
    
    func testContinue() throws {
        try runner.run { app in
            let screen = SymptomsAfterPositiveTestScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
    
    func testFurtherAdvice() throws {
        try runner.run { app in
            let screen = SymptomsAfterPositiveTestScreen(app: app)
            
            screen.furtherAdviceLink.tap()
            XCTAssert(screen.furtherAdviceAlertTitle.exists)
        }
    }
    
}

private extension SymptomsAfterPositiveTestScreen {
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[SymptomsAfterPositiveTestViewControllerScenario.returnHomeTapped]
    }
    
    var furtherAdviceAlertTitle: XCUIElement {
        app.staticTexts[SymptomsAfterPositiveTestViewControllerScenario.onlineServicesLinkTapped]
    }
}
