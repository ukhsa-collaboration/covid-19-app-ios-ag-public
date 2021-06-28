//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class LinkButtonComponentsTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LinkButtonComponentScenario>
    
    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.link.exists)
        }
    }
    
    func testLinkTapped() throws {
        try runner.run { app in
            app.link.tap()
            XCTAssert(app.linkTappedResult.exists)
        }
    }
    
}

private extension XCUIApplication {
    
    var link: XCUIElement {
        links[LinkButtonComponentScenario.linkTitle]
    }
    
    var linkTappedResult: XCUIElement {
        staticTexts[LinkButtonComponentScenario.linkTappedTitle]
    }
    
}
