//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Localization
import Scenarios
import XCTest

class LogoStraplineComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LogoStraplineComponentScenario>
    
    func testBasics() throws {
        runner.inspect { viewController in
            XCTAssertAccessibility(viewController, [
                .element {
                    $0.label = localize(.onboarding_strapline_accessiblity_label)
                    $0.traits = [.header, .staticText]
                },
            ])
        }
        try runner.run { app in
            XCTAssert(app.logoStrapline.exists)
        }
    }
    
}

private extension XCUIApplication {
    
    var logoStrapline: XCUIElement {
        staticTexts[localized: .onboarding_strapline_accessiblity_label]
    }
    
}
