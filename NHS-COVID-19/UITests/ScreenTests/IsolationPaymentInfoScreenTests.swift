//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class IsolationPaymentInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<IsolationPaymentInfoScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = IsolationPaymentInfoScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.button.exists)
        }
    }
    
    func testApply() throws {
        try runner.run { app in
            let screen = IsolationPaymentInfoScreen(app: app)
            screen.button.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.applyTapped].exists)
        }
    }
}
