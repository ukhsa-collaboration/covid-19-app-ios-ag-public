//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class TestingHubScreenNotIsolatingTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<TestingHubScreenNotIsolatingScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssertFalse(screen.bookFreeTestButton.exists)
            XCTAssertTrue(screen.findOutAboutTestingLinkButton.exists)
            XCTAssertTrue(screen.enterTestResultButton.exists)
        }
    }
    
    func testTapOnFindOutAboutTestingLinkButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.findOutAboutTestingLinkButton.exists)
            XCTAssert(screen.findOutAboutTestingLinkButton.isHittable)
            screen.findOutAboutTestingLinkButton.tap()
            
            let findOutAboutTestingAlertTitle = app.staticTexts[TestingHubScreenAlertTitle.findOutAboutTesting]
            XCTAssert(findOutAboutTestingAlertTitle.displayed)
        }
    }
    
    func testTapOnEnterTestResultButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.enterTestResultButton.exists)
            XCTAssert(screen.enterTestResultButton.isHittable)
            screen.enterTestResultButton.tap()
            
            let enterTestResultAlertTitle = app.staticTexts[TestingHubScreenAlertTitle.enterTestResult]
            XCTAssert(enterTestResultAlertTitle.displayed)
        }
    }
    
}

class TestingHubScreenIsolatingTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<TestingHubScreenIsolatingScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssertTrue(screen.bookFreeTestButton.exists)
            XCTAssertFalse(screen.findOutAboutTestingLinkButton.exists)
            XCTAssertTrue(screen.enterTestResultButton.exists)
        }
    }
    
    func testTapOnBookFreeTestButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.bookFreeTestButton.exists)
            XCTAssert(screen.bookFreeTestButton.isHittable)
            screen.bookFreeTestButton.tap()
            
            let bookFreeTestAlertTitle = app.staticTexts[TestingHubScreenAlertTitle.bookFreeTest]
            XCTAssert(bookFreeTestAlertTitle.displayed)
        }
    }
    
    func testTapOnEnterTestResultButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.enterTestResultButton.exists)
            XCTAssert(screen.enterTestResultButton.isHittable)
            screen.enterTestResultButton.tap()
            
            let enterTestResultAlertTitle = app.staticTexts[TestingHubScreenAlertTitle.enterTestResult]
            XCTAssert(enterTestResultAlertTitle.displayed)
        }
    }
    
}
