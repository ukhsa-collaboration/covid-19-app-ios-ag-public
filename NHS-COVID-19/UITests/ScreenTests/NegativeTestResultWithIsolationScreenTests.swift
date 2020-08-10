//
// Copyright © 2020 NHSX. All rights reserved.
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
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = NegativeTestResultWithIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
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
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultWithIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultWithIsolationScreenScenario.returnHomeTapped]
    }
}
