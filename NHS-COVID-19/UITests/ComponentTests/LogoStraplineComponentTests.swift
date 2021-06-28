//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import Localization
import Scenarios
import XCTest

class LogoStraplineComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LogoStraplineComponentScenario>
    
    func testBasics() throws {
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
