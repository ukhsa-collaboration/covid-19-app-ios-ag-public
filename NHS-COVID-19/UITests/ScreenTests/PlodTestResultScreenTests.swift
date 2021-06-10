//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import Scenarios

class PlodTestResultScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PlodTestResultScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PlodTestResultScreen(app: app)
            XCTAssert(screen.title.exists)
            XCTAssert(screen.subtitle.exists)
            XCTAssert(screen.description.allExist)
            XCTAssert(screen.warning.exists)
            XCTAssert(screen.primaryButton.exists)
        }
    }
    
    func testPrimaryButtonTap() throws {
        try runner.run { app in
            let screen = PlodTestResultScreen(app: app)
            
            screen.primaryButton.tap()
            XCTAssert(screen.primaryButtonAlertTitle.exists)
        }
    }
}

private extension PlodTestResultScreen {
    
    var primaryButtonAlertTitle: XCUIElement {
        app.staticTexts[PlodTestResultScreenScenario.returnHomeTapped]
    }
}
