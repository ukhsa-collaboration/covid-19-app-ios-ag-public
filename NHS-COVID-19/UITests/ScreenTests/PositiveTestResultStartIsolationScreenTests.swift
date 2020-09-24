//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Scenarios

class PositiveTestResultStartIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PositiveTestResultStartIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)
            XCTAssert(screen.daysIsolateLabel(daysRemaining: runner.scenario.daysToIsolate).exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testShareKeys() throws {
        try runner.run { app in
            let screen = PositiveTestResultStartIsolationScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
}

private extension PositiveTestResultStartIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var continueAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.primaryButtonTapped]
    }
    
    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.noThanksLinkTapped]
    }
    
}
