//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PilotActivationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PilotActivationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PilotActivationScreen(app: app)
            XCTAssert(screen.title.exists)
            screen.descriptions.forEach {
                XCTAssert($0.exists)
            }
            XCTAssert(screen.textfieldHeading.exists)
            XCTAssert(screen.textfieldExample.exists)
            XCTAssert(screen.infoHeading.exists)
            XCTAssert(screen.infoDescription1.exists)
            XCTAssert(screen.infoExample.exists)
            XCTAssert(screen.infoDescription2.exists)
            XCTAssert(screen.button.exists)
            XCTAssert(screen.textfield.exists)
        }
    }
}
