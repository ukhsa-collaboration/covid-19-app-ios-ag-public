//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PositiveTestResultScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PositiveTestResultScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveTestResultScreen(app: app)
            
            XCTAssert(screen.pleaseIsolateLabel.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = PositiveTestResultScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testShareKeys() throws {
        try runner.run { app in
            let screen = PositiveTestResultScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
}

private extension PositiveTestResultScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultScreenScenario.onlineServicesLinkTapped]
    }
    
    var continueAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultScreenScenario.continueTapped]
    }
    
    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultScreenScenario.noThanksLinkTapped]
    }
    
}
