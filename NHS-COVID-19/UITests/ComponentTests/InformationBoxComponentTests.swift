//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class InformationBoxComponentsTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<InformationBoxComponentScenario>
    
    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.shortLabel.exists)
            XCTAssert(app.longLabel.exists)
            XCTAssert(app.titleLabel.exists)
            XCTAssert(app.shortStackLabel.exists)
            XCTAssert(app.longStackLabel.exists)
            XCTAssert(app.link.exists)
            XCTAssert(app.warningLabel.exists)
            XCTAssert(app.goodNewsLabel.exists)
            XCTAssert(app.badNewsLabel.exists)
        }
    }
    
    func testLinkAction() throws {
        try runner.run { app in
            app.link.tap()
            XCTAssert(app.linkAction.exists)
        }
    }
}

private extension XCUIApplication {
    
    var shortLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.shortLabel]
    }
    
    var longLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.longLabel]
    }
    
    var titleLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.title]
    }
    
    var shortStackLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.shortStackLabel]
    }
    
    var longStackLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.longStackLabel]
    }
    
    var link: XCUIElement {
        links[InformationBoxComponentScenario.link]
    }
    
    var linkAction: XCUIElement {
        staticTexts[InformationBoxComponentScenario.linkActionText]
    }
    
    var warningLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.warningLabel]
    }
    
    var goodNewsLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.goodNewsLabel]
    }
    
    var badNewsLabel: XCUIElement {
        staticTexts[InformationBoxComponentScenario.badNewsLabel]
    }
}
