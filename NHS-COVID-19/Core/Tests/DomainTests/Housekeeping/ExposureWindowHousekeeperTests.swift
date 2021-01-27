//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class ExposureWindowHousekeeperTests: XCTestCase {
    
    var cleared = false
    
    override func setUp() {
        cleared = false
    }
    
    private func createHouseKeeper(
        isolationLogicalState: IsolationLogicalState,
        isWaitingForExposureApproval: Bool
    ) -> ExposureWindowHousekeeper {
        ExposureWindowHousekeeper(
            getIsolationLogicalState: { isolationLogicalState },
            isWaitingForExposureApproval: { isWaitingForExposureApproval },
            clearExposureWindowData: { self.cleared = true }
        )
    }
    
    func testHousekeeperClearesDataIfNotIsolatingAndNotWaitingForApproval() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            isWaitingForExposureApproval: false
        )
        
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(cleared)
    }
    
    func testHousekeeperDoesNothingIfInIsolation() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: IsolationLogicalState.isolating(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 26, timeZone: .current), reason: .indexCase(hasPositiveTestResult: false, testkitType: nil, isSelfDiagnosed: true)), endAcknowledged: false, startAcknowledged: false
            ),
            isWaitingForExposureApproval: false
        )
        
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
    
    func testHousekeeperDoesNothingIfNotInIsolationButIsWaitingForExposureApproval() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            isWaitingForExposureApproval: true
        )
        
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertFalse(cleared)
    }
}
