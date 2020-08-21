//
//  Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

import Foundation

import Foundation


class RiskLevelHighInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskLevelHighScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskLevelHighInfoScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.body.exists)
            XCTAssert(screen.linkToWebsiteLinkButton.exists)
        }
    }
    
    func testTapLinkToWebsite() throws {
        try runner.run { app in
            let screen = RiskLevelHighInfoScreen(app: app)
            
            screen.linkToWebsiteLinkButton.tap()
            XCTAssert(screen.linktoWebsiteAlertTitle.exists)
        }
    }
}

private extension RiskLevelHighInfoScreen {
    
    var linktoWebsiteAlertTitle: XCUIElement {
        app.staticTexts[RiskLevelHighScreenScenario.linkButtonTaped]
    }
}
