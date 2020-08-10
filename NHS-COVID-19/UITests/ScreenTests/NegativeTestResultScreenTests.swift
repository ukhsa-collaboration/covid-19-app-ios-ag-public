//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class NegativeTestResultScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<NegativeTestResultScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = NegativeTestResultScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.endOfIsolationLabel.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = NegativeTestResultScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testReturnHome() throws {
        try runner.run { app in
            let screen = NegativeTestResultScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
}

private extension NegativeTestResultScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultScreenScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NegativeTestResultScreenScenario.returnHomeTapped]
    }
}
