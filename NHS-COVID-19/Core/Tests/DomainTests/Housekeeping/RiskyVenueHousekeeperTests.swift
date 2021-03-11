//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class RiskyVenueHousekeeperTests: XCTestCase {
    
    var cleared = false
    
    override func setUp() {
        cleared = false
    }
    
    private func createHouseKeeper(
        deletionPeriod: Int,
        today: GregorianDay,
        mostRecentCheckInDay: GregorianDay?
    ) -> RiskyVenueHousekeeper {
        RiskyVenueHousekeeper(
            getHousekeepingDeletionPeriod: { DayDuration(deletionPeriod) },
            getMostRecentCheckInDay: { mostRecentCheckInDay },
            getToday: { today },
            clearData: { self.cleared = true }
        )
    }
    
    func testHousekeeperDoesNothingIfNoRiskyVenueInfo() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 5,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            mostRecentCheckInDay: nil
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfUnderDeletionPeriod() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 5,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            mostRecentCheckInDay: GregorianDay(year: 2020, month: 7, day: 24)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperClearsIfOverDeletionPeriod() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 5,
            today: GregorianDay(year: 2020, month: 7, day: 24).advanced(by: 5),
            mostRecentCheckInDay: GregorianDay(year: 2020, month: 7, day: 24)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
}
