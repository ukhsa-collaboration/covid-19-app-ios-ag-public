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
                    $0.label = runner.scenario.actionTitle
                    $0.traits = .button
                },
            ])
        }
        
        try runner.run { app in
            XCTAssert(app.statusTitle.exists)
            XCTAssert(app.explanationTitle.exists)
            XCTAssert(app.actionButton.exists)
        }
    }
    
    func testAction() throws {
        try runner.run { app in
            app.actionButton.tap()
            XCTAssert(app.actionResult.exists)
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
    
    var actionButton: XCUIElement {
        buttons[CheckInStatusScreenTemplateScenario.actionTitle]
    }
    
    var actionResult: XCUIElement {
        staticTexts[CheckInStatusScreenTemplateScenario.didPerformActionTitle]
    }
    
}
