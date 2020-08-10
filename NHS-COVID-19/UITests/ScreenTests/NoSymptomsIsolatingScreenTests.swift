//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

import Foundation

class NoSymptomsIsolatingScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<NoSymptomsIsolatingViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = NoSymptomsIsolatingScreen(app: app)
            
            XCTAssert(screen.continueToIsolateLabel.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.adviceLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = NoSymptomsIsolatingScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testReturnHome() throws {
        try runner.run { app in
            let screen = NoSymptomsIsolatingScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
}

private extension NoSymptomsIsolatingScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsIsolatingViewControllerScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[NoSymptomsIsolatingViewControllerScenario.returnHomeTapped]
    }
}
