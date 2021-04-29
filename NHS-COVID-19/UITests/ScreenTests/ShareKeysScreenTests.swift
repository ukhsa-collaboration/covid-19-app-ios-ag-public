//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ShareKeysScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ShareKeysScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ShareKeysScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.privacyBanner.exists)
            XCTAssertTrue(screen.howDoesItHelpHeading.exists)
            XCTAssertTrue(screen.howDoesItHelpBody.exists)
            XCTAssertTrue(screen.whatIsARandomIDHeading.exists)
            XCTAssertTrue(screen.whatIsARandomIDBody.exists)
            XCTAssertTrue(screen.notifyButton.exists)
        }
    }
    
    func testNotifyButton() throws {
        try runner.run { app in
            let screen = ShareKeysScreen(app: app)
            screen.notifyButton.tap()
            XCTAssertTrue(app.staticTexts["'Continue' tapped"].exists)
        }
    }
    
}
