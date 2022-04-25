//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class EndOfIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runnerIndexCaseEngland: ApplicationRunner<EndOfIsolationForIndexCaseEnglandScreenScenario>
    
    @Propped
    private var runnerContactCaseEngland: ApplicationRunner<EndOfIsolationForContactCaseEnglandScreenScenario>
    
    @Propped
    private var runnerIndexCaseWales: ApplicationRunner<EndOfIsolationForIndexCaseWalesScreenScenario>
    
    @Propped
    private var runnerContactCaseWales: ApplicationRunner<EndOfIsolationForContactCaseWalesScreenScenario>
    
    func testBasicsIndexCaseEngland() throws {
        try runnerIndexCaseEngland.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
            XCTAssertFalse(screen.openGuidanceLinkButton.exists)
        }
    }
    
    func testBasicsContactCaseEngland() throws {
        try runnerContactCaseEngland.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
            XCTAssertFalse(screen.indicationLabel.exists)
            XCTAssertFalse(screen.openGuidanceLinkButton.exists)
        }
    }
    
    func testBasicsIndexCaseWales() throws {
        try runnerIndexCaseWales.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.titleIndexCaseWales.exists)
            XCTAssert(screen.calloutBoxIndexCaseWales.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
            XCTAssert(screen.openGuidanceLinkButton.exists)
        }
    }
    
    func testBasicsContactCaseWales() throws {
        try runnerContactCaseWales.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.returnHomeButton.exists)
            XCTAssertFalse(screen.calloutBoxIndexCaseWales.exists)
            XCTAssertFalse(screen.openGuidanceLinkButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runnerIndexCaseEngland.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
            XCTAssertFalse(screen.primaryLinkAlertTitle.exists)
        }
    }
    
    func testReturnHome() throws {
        try runnerIndexCaseEngland.run { app in
            let screen = EndOfIsolationScreen(app: app)
            
            screen.returnHomeButton.tap()
            XCTAssert(screen.returnHomeAlertTitle.exists)
            XCTAssertFalse(screen.primaryLinkAlertTitle.exists)
        }
    }
    
    func testToOpenGuidanceLink() throws {
        try runnerIndexCaseWales.run { app in
            let screen = EndOfIsolationScreen(app: app)
            screen.openGuidanceLinkButton.tap()
            
            XCTAssert(screen.primaryLinkAlertTitle.exists)
        }
    }
}

private extension EndOfIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationForIndexCaseWalesScreenScenario.onlineServicesLinkTapped]
    }
    
    var returnHomeAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationForIndexCaseWalesScreenScenario.returnHomeTapped]
    }
    
    var primaryLinkAlertTitle: XCUIElement {
        app.staticTexts[EndOfIsolationForIndexCaseWalesScreenScenario.primaryLinkTapped]
    }
    
}
