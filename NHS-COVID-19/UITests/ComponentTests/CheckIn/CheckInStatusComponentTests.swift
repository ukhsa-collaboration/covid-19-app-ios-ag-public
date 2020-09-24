//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class CheckInStatusComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<CheckInStatusScreenTemplateScenario>
    
    func testBasics() throws {
        runner.inspect { viewController in
            XCTAssertAccessibility(viewController, [
                .element {
                    $0.label = runner.scenario.statusTitle
                    $0.traits = [.header]
                },
                .element {
                    $0.label = runner.scenario.explanationTitle
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.helpLinkTitle
                    $0.traits = .link
                },
                .element {
                    $0.label = runner.scenario.moreExplanationTitle
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.actionTitle
                    $0.traits = .button
                },
            ])
        }
        
        try runner.run { app in
            XCTAssert(app.statusTitle.exists)
            XCTAssert(app.explanationTitle.exists)
            XCTAssert(app.helpLink.exists)
            XCTAssert(app.moreExplanationTitle.exists)
            XCTAssert(app.actionButton.exists)
        }
    }
    
    func testAction() throws {
        try runner.run { app in
            app.actionButton.tap()
            XCTAssert(app.actionResult.exists)
        }
    }
    
    func testHelpLink() throws {
        try runner.run { app in
            app.helpLink.tap()
            XCTAssert(app.helpLinkResult.exists)
        }
    }
    
}

private extension XCUIApplication {
    
    var statusTitle: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.statusTitle]
    }
    
    var explanationTitle: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.explanationTitle]
    }
    
    var helpLink: XCUIElement {
        links[CheckInStatusScreenTemplateScenario.helpLinkTitle]
    }
    
    var moreExplanationTitle: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.moreExplanationTitle]
    }
    
    var actionButton: XCUIElement {
        buttons[CheckInStatusScreenTemplateScenario.actionTitle]
    }
    
    var actionResult: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.didPerformActionTitle]
    }
    
    var helpLinkResult: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.didPerformShowHelpActionTitle]
    }
    
}
