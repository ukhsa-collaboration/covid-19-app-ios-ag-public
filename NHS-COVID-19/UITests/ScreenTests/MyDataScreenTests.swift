//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class MyDataScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<MyDataScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            
            XCTAssertTrue(screen.title.displayed)
            XCTAssertTrue(app.staticTexts[runner.scenario.postcode].displayed)
            XCTAssertTrue(app.staticTexts[runner.scenario.testResult.description].displayed)
            
            app.scrollTo(element: screen.deleteDataButton)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID1].displayed)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID2].displayed)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID3].displayed)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID4].displayed)
            XCTAssertTrue(screen.deleteDataButton.displayed)
        }
    }
}
