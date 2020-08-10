//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class RiskyVenueInformationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<RiskyVenueInformationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = RiskyVenueInformationScreen(
                app: app,
                venueName: runner.scenario.venueName,
                checkInDate: runner.scenario.checkInDate
            )
            
            XCTAssertTrue(screen.title.displayed)
            XCTAssertTrue(screen.description.displayed)
            
            screen.actionButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.goHomeTapped].displayed)
        }
    }
}
