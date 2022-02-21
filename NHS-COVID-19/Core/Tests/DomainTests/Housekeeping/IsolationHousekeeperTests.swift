//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class IsolationHousekeeperTests: XCTestCase {
    
    var cleared = false
    
    override func setUp() {
        cleared = false
    }
    
    private func createHouseKeeper(deletionPeriod: Int,
                                   today: GregorianDay,
                                   isolationInfo: IsolationInfo,
                                   isolationLogicalState: IsolationLogicalState) -> IsolationHousekeeper {
        IsolationHousekeeper(
            getHousekeepingDeletionPeriod: { DayDuration(deletionPeriod) },
            getToday: { today },
            getIsolationLogicalState: { isolationLogicalState },
            getIsolationStateInfo: { isolationInfo },
            clearData: { self.cleared = true }
        )
    }
    
    // MARK: Housekeeper does nothing
    
    func testHousekeeperDoesNothingIfNoIsolationInfo() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfStillIsolating() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(),
            isolationLogicalState: IsolationLogicalState.isolating(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 26, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)), endAcknowledged: false, startOfContactIsolationAcknowledged: false
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfIsolationEndNotAcknowledged() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(),
            isolationLogicalState: IsolationLogicalState.isolationFinishedButNotAcknowledged(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 23, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
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
            isolationInfo: IsolationInfo(),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 20, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldClearIfDeletionPeriodHasPassed() throws {
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 8, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
            )
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldClearManualTestEntryOfNegativeTestIfDeletionPeriodHasPassed() throws {
        let testEndDay = GregorianDay(year: 2020, month: 7, day: 10)
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(indexCaseInfo: IndexCaseInfo(symptomaticInfo: nil, testInfo: IndexCaseInfo.TestInfo(result: .negative, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: GregorianDay(year: 2020, month: 7, day: 24), testEndDay: testEndDay)), contactCaseInfo: nil),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                nil)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperShouldNotClearManualTestEntryOfNegativeTestIfDeletionPeriodHasNotPassed() throws {
        let testEndDay = GregorianDay(year: 2020, month: 7, day: 11)
        let housekeeper = createHouseKeeper(
            deletionPeriod: 14,
            today: GregorianDay(year: 2020, month: 7, day: 24),
            isolationInfo: IsolationInfo(indexCaseInfo: IndexCaseInfo(symptomaticInfo: nil, testInfo: IndexCaseInfo.TestInfo(result: .negative, requiresConfirmatoryTest: false, shouldOfferFollowUpTest: false, receivedOnDay: GregorianDay(year: 2020, month: 7, day: 24), testEndDay: testEndDay)), contactCaseInfo: nil),
            isolationLogicalState: IsolationLogicalState.notIsolating(finishedIsolationThatWeHaveNotDeletedYet:
                nil)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
}
