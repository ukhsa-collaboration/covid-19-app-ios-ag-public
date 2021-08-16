//
// Copyright © 2021 DHSC. All rights reserved.
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
            XCTAssertTrue(screen.description.allExist)
            
            screen.actionButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.goHomeTapped].displayed)
        }
    }
}
