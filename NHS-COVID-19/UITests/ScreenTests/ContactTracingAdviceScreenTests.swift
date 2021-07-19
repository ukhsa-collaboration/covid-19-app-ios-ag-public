//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactTracingAdviceShouldNotPauseScreenTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<ContactTracingAdviceScreenShouldNotPauseScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactTracingAdviceScreen(app: app)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.bulletItems.allExist)
            XCTAssertTrue(screen.footnote.exists)
        }
    }
    
}
