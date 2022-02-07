//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class LocalStatisticsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<LocalStatisticsScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = LocalStatisticsScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.navigationTitle.exists)
            XCTAssertTrue(screen.generalInfo.exists)
            XCTAssertTrue(screen.lastUpdated(date: LocalStatisticsScreenScenario.lastFetchedDate).exists)
            XCTAssertTrue(screen.moreInfo.exists)
            XCTAssertTrue(screen.dashboardLink.exists)
        }
    }
    
    func testLinkButton() throws {
        try runner.run { app in
            let screen = LocalStatisticsScreen(app: app)
            screen.dashboardLink.tap()
            XCTAssertTrue(app.staticTexts[LocalStatisticsScreenScenario.dashboardLinkButtonTapped].exists)
        }
    }
}
