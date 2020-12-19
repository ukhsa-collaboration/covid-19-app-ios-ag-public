//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class VoidTestResultNoIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<VoidTestResultNoIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = VoidTestResultNoIsolationScreen(app: app)
            XCTAssert(screen.title.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
            XCTAssert(screen.cancelButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = VoidTestResultNoIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testPrimaryButtonTap() throws {
        try runner.run { app in
            let screen = VoidTestResultNoIsolationScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
    
    func testCancelButtonTap() throws {
        try runner.run { app in
            let screen = VoidTestResultNoIsolationScreen(app: app)
            
            screen.cancelButton.tap()
            XCTAssert(screen.cancelAlertTitle.exists)
        }
    }
}

private extension VoidTestResultNoIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultNoIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var continueAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultNoIsolationScreenScenario.continueTapped]
    }
    
    var cancelAlertTitle: XCUIElement {
        app.staticTexts[VoidTestResultNoIsolationScreenScenario.cancelTapped]
    }
}
