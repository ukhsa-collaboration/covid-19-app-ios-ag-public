//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class BulletPointComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<BulletPointComponentScenario>
    
    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.firstBulletPoint.displayed)
            XCTAssert(app.secondBulletPoint.displayed)
            XCTAssert(app.thirdBulletPoint.displayed)
        }
    }
    
}

private extension XCUIApplication {
    
    var firstBulletPoint: XCUIElement {
        staticTexts[localized: .numbered_list_item(index: 1, text: BulletPointComponentScenario.shortLabel)]
    }
    
    var secondBulletPoint: XCUIElement {
        staticTexts[localized: .numbered_list_item(index: 2, text: BulletPointComponentScenario.longLabel)]
    }
    
    var thirdBulletPoint: XCUIElement {
        staticTexts[localized: .numbered_list_item(index: 3, text: BulletPointComponentScenario.veryLongLabel)]
    }
    
}
