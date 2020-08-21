import Scenarios
import XCTest

import Foundation


class RiskLevelMediumInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskLevelMediumScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskLevelMediumInfoScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.body.exists)
            XCTAssert(screen.linkToWebsiteLinkButton.exists)
        }
    }
    
    func testTapLinkToWebsite() throws {
        try runner.run { app in
            let screen = RiskLevelMediumInfoScreen(app: app)
            
            screen.linkToWebsiteLinkButton.tap()
            XCTAssert(screen.linktoWebsiteAlertTitle.exists)
        }
    }
}

private extension RiskLevelMediumInfoScreen {
    
    var linktoWebsiteAlertTitle: XCUIElement {
        app.staticTexts[RiskLevelMediumScreenScenario.linkButtonTaped]
    }
}
