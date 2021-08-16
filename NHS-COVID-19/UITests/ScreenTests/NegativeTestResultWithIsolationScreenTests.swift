//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

import Foundation

class NegativeTestResultWithIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<NegativeTestResultWithIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = NegativeTestResultWithIsolationScreen(app: app)
            
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.nhsGuidanceLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapNHSGuidance() throws {
        try runner.run { app in
            let screen = NegativeTestResultWithIsolationScreen(app: app)
            
            screen.nhsGuidanceLink.tap()
            XCTAssert(screen.nhsGuidanceLinkAlertTitle.exists)
        }
    }
    
    func testReturnHome() throws {
        try runner.run { app in
            let screen = NegativeTestResultWithIsolationScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
}

private extension NegativeTestResultWithIsolationScreen {
    
    var nhsGuidanceLinkAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultWithIsolationScreenScenario.nhsGuidanceTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultWithIsolationScreenScenario.returnHomeTapped]
    }
}
