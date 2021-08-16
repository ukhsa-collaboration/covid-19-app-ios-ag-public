//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import Scenarios
import XCTest

class HubButtonCellComponentTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<HubButtonCellComponentScenario>
    
    func testBasics() throws {
        try runner.run { app in
            XCTAssert(app.firstHubButtonCell.exists)
            XCTAssert(app.secondHubButtonCell.exists)
        }
    }
    
    func testFirstHubButtonCellTapped() throws {
        try runner.run { app in
            app.firstHubButtonCell.tap()
            XCTAssert(app.firstHubButtoCellAlert.exists)
        }
    }
    
    func testSecondHubButtonCellTapped() throws {
        try runner.run { app in
            app.secondHubButtonCell.tap()
            XCTAssert(app.secondHubButtoCellAlert.exists)
        }
    }
    
}

private extension XCUIApplication {
    
    var firstHubButtonCell: XCUIElement {
        buttons[HubButtonCellComponentScenario.firstHubButtonCellTitle + ", " + HubButtonCellComponentScenario.firstHubButtonCellDescription]
    }
    
    var firstHubButtoCellAlert: XCUIElement {
        staticTexts[HubButtonCellComponentScenario.Alerts.firstHubButtoCellAlert.rawValue]
    }
    
    var secondHubButtonCell: XCUIElement {
        links[HubButtonCellComponentScenario.secondHubButtonCellTitle + ", " + HubButtonCellComponentScenario.secondHubButtonCellDescription]
    }
    
    var secondHubButtoCellAlert: XCUIElement {
        staticTexts[HubButtonCellComponentScenario.Alerts.secondHubButtonCellAlert.rawValue]
    }
    
}
