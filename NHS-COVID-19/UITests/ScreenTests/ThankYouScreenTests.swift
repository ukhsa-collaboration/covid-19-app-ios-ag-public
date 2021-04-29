//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ThankYouScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ThankYouScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ThankYouScreen(app: app)
            XCTAssert(screen.headingText.exists)
            XCTAssert(screen.backHomeButtonText.exists)
        }
    }
}
