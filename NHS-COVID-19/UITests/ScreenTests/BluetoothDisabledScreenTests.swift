//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class BluetoothDisabledScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<BluetoothDisabledScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = BluetoothDisabledScreen(app: app)
            
            XCTAssert(screen.errorTitle.exists)
            XCTAssert(screen.description.allExist)
        }
    }
}
