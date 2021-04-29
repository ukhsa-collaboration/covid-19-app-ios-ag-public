//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ShareKeysReminderScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ShareKeysReminderScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ShareKeysReminderScreen(app: app)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.subHeading.exists)
            XCTAssertTrue(screen.privacyBanner.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.shareButton.exists)
            XCTAssertTrue(screen.doNotShareButton.exists)
        }
    }
    
    
    func testShareButton() throws {
        try runner.run { app in
            let screen = ShareKeysReminderScreen(app: app)
            screen.shareButton.tap()
            XCTAssertTrue(screen.shareAlertTitle.exists)
        }
    }
    
    func testDoNotShareButton() throws {
        try runner.run { app in
            let screen = ShareKeysReminderScreen(app: app)
            screen.doNotShareButton.tap()
            XCTAssertTrue(screen.doNotShareAlertTitle.exists)
        }
    }
}

private extension ShareKeysReminderScreen {
            
    var shareAlertTitle: XCUIElement {
        app.staticTexts[ShareKeysReminderScreenScenario.shareTapped]
    }
    
    var doNotShareAlertTitle: XCUIElement {
        app.staticTexts[ShareKeysReminderScreenScenario.doNotShareTapped]
    }
    
}
