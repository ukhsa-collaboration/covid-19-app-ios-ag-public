//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class OnboardingStepComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<OnboardingStepScreenTemplateScenario>
    
    func testBasics() throws {
        runner.inspect { viewController in
            XCTAssertAccessibility(viewController, [
                .element {
                    $0.label = runner.scenario.straplineTitle
                    $0.traits = [.staticText, .header]
                },
                .element {
                    $0.label = runner.scenario.stepTitle
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.customViewContent
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.customViewContent2
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.customViewContent3
                    $0.traits = .staticText
                },
                .element {
                    $0.label = runner.scenario.actionTitle
                    $0.traits = .button
                },
            ])
        }
        try runner.run { app in
            XCTAssert(app.stepTitle.exists)
            XCTAssert(app.customContent.exists)
            XCTAssert(app.customContent2.exists)
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
    
    var stepTitle: XCUIElement {
        staticTexts[OnboardingStepScreenTemplateScenario.stepTitle]
    }
    
    var actionButton: XCUIElement {
        buttons[OnboardingStepScreenTemplateScenario.actionTitle]
    }
    
    var customContent: XCUIElement {
        staticTexts[OnboardingStepScreenTemplateScenario.customViewContent]
    }
    
    var customContent2: XCUIElement {
        staticTexts[OnboardingStepScreenTemplateScenario.customViewContent2]
    }
    
    var actionResult: XCUIElement {
        staticTexts[OnboardingStepScreenTemplateScenario.didPerformActionTitle]
    }
    
}
