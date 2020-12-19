//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Scenarios

class VoidTestResultWithIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<VoidTestResultWithIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)
            XCTAssert(screen.daysIsolateLabel(daysRemaining: runner.scenario.daysToIsolate).exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testPrimaryButtonTap() throws {
        try runner.run { app in
            let screen = VoidTestResultWithIsolationScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.primaryButtonAlertTitle.exists)
        }
    }
}

private extension VoidTestResultWithIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var primaryButtonAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.primaryButtonTapped]
    }
    
    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultWithIsolationScreenScenario.noThanksLinkTapped]
    }
    
}
