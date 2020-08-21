//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

import Foundation

class RiskLevelLowInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskLevelLowScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskLevelLowInfoScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.body.exists)
            XCTAssert(screen.linkToWebsiteLinkButton.exists)
        }
    }
    
    func testTapLinkToWebsite() throws {
        try runner.run { app in
            let screen = RiskLevelLowInfoScreen(app: app)
            
            screen.linkToWebsiteLinkButton.tap()
            XCTAssert(screen.linktoWebsiteAlertTitle.exists)
        }
    }
}


private extension RiskLevelLowInfoScreen {
    
    var linktoWebsiteAlertTitle: XCUIElement {
        app.staticTexts[RiskLevelLowScreenScenario.linkButtonTaped]
    }
}
