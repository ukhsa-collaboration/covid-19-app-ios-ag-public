//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class BookATestScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<BookATestInfoScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = BookATestScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.paragraph4.exists)
            XCTAssertTrue(screen.paragraph5.exists)
            XCTAssertTrue(screen.testingPrivacyNotice.exists)
            XCTAssertTrue(screen.appPrivacyNotice.exists)
            XCTAssertTrue(screen.bookATestForSomeoneElse.exists)
            XCTAssertTrue(screen.button.exists)
        }
    }
    
    func testBookATest() throws {
        try runner.run { app in
            let screen = BookATestScreen(app: app)
            screen.button.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookATestTapped].exists)
        }
    }
    
    func testBookATestForSomeoneElse() throws {
        try runner.run { app in
            let screen = BookATestScreen(app: app)
            screen.bookATestForSomeoneElse.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.bookTestForSomeoneElseTapped].exists)
        }
    }
    
    func testAppPrivacyNoticeLinkAction() throws {
        try runner.run { app in
            let screen = BookATestScreen(app: app)
            screen.appPrivacyNotice.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.appPrivacyNoticeTapped].exists)
        }
    }
    
    func testTestingPrivacyNoticeLinkAction() throws {
        try runner.run { app in
            let screen = BookATestScreen(app: app)
            screen.testingPrivacyNotice.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.testingPrivacyNoticeTapped].exists)
        }
    }
    
}
