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
            XCTAssertTrue(screen.orderTestKitLinkButton.exists)
            XCTAssertTrue(screen.enterTestResultButton.exists)
        }
    }
    
    func testTapOnOrderTestKitLinkButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.orderTestKitLinkButton.exists)
            XCTAssert(screen.orderTestKitLinkButton.isHittable)
            screen.orderTestKitLinkButton.tap()
            
            XCTAssert(app.staticTexts[TestingHubScreenAlertTitle.orderAFreeTestingKit].displayed)
        }
    }
    
    func testTapOnEnterTestResultButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.enterTestResultButton.exists)
            XCTAssert(screen.enterTestResultButton.isHittable)
            screen.enterTestResultButton.tap()
            
            XCTAssert(app.staticTexts[TestingHubScreenAlertTitle.enterTestResult].displayed)
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
            XCTAssertFalse(screen.orderTestKitLinkButton.exists)
            XCTAssertTrue(screen.enterTestResultButton.exists)
        }
    }
    
    func testTapOnBookFreeTestButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.bookFreeTestButton.exists)
            XCTAssert(screen.bookFreeTestButton.isHittable)
            screen.bookFreeTestButton.tap()
            
            XCTAssert(app.staticTexts[TestingHubScreenAlertTitle.bookFreeTest].displayed)
        }
    }
    
    func testTapOnEnterTestResultButton() throws {
        try runner.run { app in
            let screen = TestingHubScreen(app: app)
            
            XCTAssert(screen.enterTestResultButton.exists)
            XCTAssert(screen.enterTestResultButton.isHittable)
            screen.enterTestResultButton.tap()
            
            XCTAssert(app.staticTexts[TestingHubScreenAlertTitle.enterTestResult].displayed)
        }
    }
    
}
