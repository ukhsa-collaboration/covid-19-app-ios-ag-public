//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Scenarios
import XCTest

class DynamicRiskLevelScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<DynamicRiskLevelScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskLevelHighInfoScreen(app: app)
            
            XCTAssert(screen.screenTitle.exists)
            screen.heading.forEach { XCTAssert($0.exists) }
            screen.body.forEach { XCTAssert($0.exists) }
            screen.footer.forEach { XCTAssert($0.exists) }
            screen.policyHeadings.forEach { XCTAssert($0.exists) }
            screen.policyContents.forEach { XCTAssert($0.exists) }
            XCTAssert(screen.title.exists)
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
        app.staticTexts[DynamicRiskLevelScreenScenario.linkButtonTaped]
    }
    
    var linkToWebsiteLinkButton: XCUIElement {
        app.links[verbatim: DynamicRiskLevelScreenScenario.linkTitle]
    }
    
    var heading: [XCUIElement] {
        DynamicRiskLevelScreenScenario.heading.map {
            app.staticTexts[verbatim: $0]
        }
    }
    
    var body: [XCUIElement] {
        DynamicRiskLevelScreenScenario.body.map {
            app.staticTexts[verbatim: $0]
        }
    }
    
    var footer: [XCUIElement] {
        DynamicRiskLevelScreenScenario.footer.map {
            app.staticTexts[verbatim: $0]
        }
    }
    
    var policyHeadings: [XCUIElement] {
        DynamicRiskLevelScreenScenario.policyHeadings.map {
            app.staticTexts[verbatim: $0]
        }
    }
    
    var policyContents: [XCUIElement] {
        DynamicRiskLevelScreenScenario.policyContents.map {
            app.staticTexts[verbatim: $0]
        }
    }
    
    var title: XCUIElement {
        app.staticTexts[verbatim: DynamicRiskLevelScreenScenario.title]
    }
}
