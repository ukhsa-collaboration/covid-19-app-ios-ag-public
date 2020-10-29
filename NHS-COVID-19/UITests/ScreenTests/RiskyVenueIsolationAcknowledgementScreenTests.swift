//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class RiskyVenueIsolationAcknowledgementScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskyVenueAcknowledgementScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskyVenueIsolationAcknowledgementScreen(app: app)
            
            XCTAssert(screen.pleaseIsolate(daysRemaining: Int(runner.scenario.days)).exists)
            XCTAssert(screen.warningBox.exists)
            XCTAssert(screen.description.allExist)
            XCTAssert(screen.linkLabel.exists)
            XCTAssert(screen.link.exists)
            XCTAssert(screen.button.exists)
        }
    }
    
    func testIUnderstandButton() throws {
        try runner.run { app in
            let screen = RiskyVenueIsolationAcknowledgementScreen(app: app)
            
            screen.button.tap()
            let alert = app.staticTexts[verbatim: runner.scenario.acknowledgedNotification]
            XCTAssert(alert.exists)
        }
    }
}
