//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class EndOfIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<EndOfIsolationWithAdvisoryScreenScenario>
    
    @Propped
    private var runnerWithoutWarning: ApplicationRunner<EndOfIsolationWithoutAdvisoryScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testReturnHome() throws {
        try runner.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
        }
    }
    
    func testHidingAdvisory() throws {
        try runnerWithoutWarning.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssertFalse(screen.indicationLabel.exists)
        }
    }
}

private extension EndOfIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationWithAdvisoryScreenScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationWithAdvisoryScreenScenario.returnHomeTapped]
    }
    
    var furtherAdviceLinkAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationWithAdvisoryScreenScenario.furtherAdviceLinkTapped]
    }
    
}
