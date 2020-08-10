//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class UnrecoverableErrorScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<UnrecoverableErrorScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = UnrecoverableErrorScreen(app: app)
            
            XCTAssert(screen.titleLabel.exists)
        }
    }
    
}
