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
                                   isolationLogicalState: IsolationLogicalState,
                                   hasPendingTestTokens: Bool) -> Housekeeper {
        Housekeeper(
            getHousekeepingDeletionPeriod: { DayDuration(deletionPeriod) },
            getToday: { today },
            getIsolationLogicalState: { isolationLogicalState },
            hasPendingTestTokens: { hasPendingTestTokens },
            clearData: { self.cleared = true }
        )
    }
    
    // MARK: Housekeeper does nothing
    
    func testHousekeeperDoesNothingIfNoIsolationInfo() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            hasPendingTestTokens: false
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfStillIsolating() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.isolating(
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 26, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false)), endAcknowledged: false, startAcknowledged: false
            ),
            hasPendingTestTokens: true
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfIsolationEndNotAcknowledged() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.isolationFinishedButNotAcknowledged(
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 23, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: false
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfDeletionPeriodNotPassedAndPendingTokensAvailable() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 14, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: true
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfDeletionPeriodNotPassedAtLimitAndPendingTask() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 4,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 21, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: true
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    // MARK: Housekeeper clears up
    
    func testHousekeeperShouldClearIfDeletionPeriodNotPassedAndNoPendingTasks() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 14, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: false
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldClearIfDeletionPeriodHasPassedAtLimit() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 4,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 20, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: true
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldClearIfDeletionPeriodHasPassed() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(untilStartOfDay: LocalDay(year: 2020, month: 7, day: 8, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false))
            ),
            hasPendingTestTokens: true
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
}
