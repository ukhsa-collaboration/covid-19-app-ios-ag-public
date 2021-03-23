//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class MyAreaScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<MyAreaScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = MyAreaScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.edit.exists)
            
            // checking the cells' value
            XCTAssertTrue(screen.postcodeCellValue(postcode: runner.scenario.postcode).exists)
            XCTAssertTrue(screen.localAuthorityCellValue(localAuthority: runner.scenario.localAuthority).exists)
            
            // checking the cells' title
            XCTAssertTrue(screen.postcodeCellTitle.exists)
            XCTAssertTrue(screen.localAuthorityCellTitle.exists)
        }
    }
    
    func testTappingEdit() throws {
        try runner.run { app in
            let screen = MyAreaScreen(app: app)
            
            screen.edit.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.editTappeed].exists)
        }
    }
}
