//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class StopIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<StopIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = StopIsolationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.body.allExist)
            XCTAssert(screen.primaryButton.exists)
        }
    }
    
    func testStopIsolationButtonTapped() throws {
        try runner.run { app in
            let screen = StopIsolationScreen(app: app)
            
            screen.primaryButton.tap()
            let alert = app.staticTexts[verbatim: runner.scenario.stopIsolationTapped]
            XCTAssert(alert.exists)
        }
    }
}
