//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class VenueHistoryScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<VenueHistoryScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = VenueHistoryScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.editVenueHistoryButton.exists)
            XCTAssertTrue(screen.dateHeader(runner.scenario.checkinDate1).exists)
            XCTAssertTrue(screen.dateHeader(runner.scenario.checkinDate2).exists)
        }
    }
    
    func testEditButton() throws {
        try runner.run { app in
            let screen = VenueHistoryScreen(app: app)
            XCTAssertTrue(screen.editVenueHistoryButton.exists)
            screen.editVenueHistoryButton.tap()
            XCTAssertTrue(screen.doneVenueHistoryButton.exists)
            screen.doneVenueHistoryButton.tap()
            XCTAssertTrue(screen.editVenueHistoryButton.exists)
        }
    }
    
    func testDeleteWholeVenueHistoryAndHideEditButton() throws {
        try runner.run { app in
            let screen = VenueHistoryScreen(app: app)
            for venueName in runner.scenario.venueNames {
                let elementToDelete = app.staticTexts[venueName]
                app.scrollToHittable(element: elementToDelete)
                elementToDelete.swipeLeft()
                
                XCTAssertTrue(screen.cellDeleteButton.exists)
                screen.cellDeleteButton.tap()
            }
            XCTAssertFalse(screen.editVenueHistoryButton.exists)
        }
    }
    
    func testPostcodeDisplay() throws {
        try runner.run { app in
            let screen = VenueHistoryScreen(app: app)
            for venueName in runner.scenario.venueNames {
                let element = app.staticTexts[venueName]
                XCTAssertTrue(element.exists)
            }
            for venuePostcode in runner.scenario.venuePostcodes {
                let formattedPostcode = venuePostcode.map { "\($0.prefix($0.count - 3)) \($0.suffix(3))" }
                
                let element = screen.cellPostcodeLabel(formattedPostcode)
                XCTAssertTrue(element.exists)
            }
        }
    }
}
