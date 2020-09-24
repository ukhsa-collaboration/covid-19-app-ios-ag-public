//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class HousekeeperTests: XCTestCase {
    
    var cleared = false
    
    override func setUp() {
        cleared = false
    }
    
    private func createHouseKeeper(deletionPeriod: Int,
                                   today: GregorianDay,
                                   isolationLogicalState: IsolationLogicalState) -> Housekeeper {
        Housekeeper(
            getHousekeepingDeletionPeriod: { DayDuration(deletionPeriod) },
            getToday: { today },
            getIsolationLogicalState: { isolationLogicalState },
            clearData: { self.cleared = true }
        )
    }
    
    // MARK: Housekeeper does nothing
    
    func testHousekeeperDoesNothingIfNoIsolationInfo() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfStillIsolating() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.isolating(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 26, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: false, startAcknowledged: false
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfIsolationEndNotAcknowledged() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.isolationFinishedButNotAcknowledged(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 23, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    // MARK: Housekeeper clears up
    
    func testHousekeeperShouldClearIfDeletionPeriodHasPassedAtLimit() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 4,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 20, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldClearIfDeletionPeriodHasPassed() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 8, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
}
