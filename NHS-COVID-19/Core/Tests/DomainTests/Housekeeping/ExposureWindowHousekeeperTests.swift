//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class ExposureWindowHousekeeperTests: XCTestCase {

    // we're just checking that the hosekeeping function is called, not that
    // the windows are deleted - that's done ExposureNotificationContextTests
    var deleteExpiredExposureWindowsCalled = false

    override func setUp() {
        deleteExpiredExposureWindowsCalled = false
    }

    private func createHouseKeeper(
        isolationLogicalState: IsolationLogicalState,
        isWaitingForExposureApproval: Bool
    ) -> ExposureWindowHousekeeper {
        ExposureWindowHousekeeper(
            deleteExpiredExposureWindows: { self.deleteExpiredExposureWindowsCalled = true }
        )
    }

    func testHousekeeperClearesDataIfNotIsolatingAndNotWaitingForApproval() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            isWaitingForExposureApproval: false
        )

        _ = housekeeper.executeHousekeeping()

        XCTAssertTrue(deleteExpiredExposureWindowsCalled)
    }

    func testHousekeeperStillWorksIfInIsolation() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: IsolationLogicalState.isolating(
                Isolation(fromDay: .today, untilStartOfDay: LocalDay(year: 2020, month: 7, day: 26, timeZone: .current), reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)), endAcknowledged: false, startOfContactIsolationAcknowledged: false
            ),
            isWaitingForExposureApproval: false
        )

        _ = housekeeper.executeHousekeeping()

        XCTAssert(deleteExpiredExposureWindowsCalled)
    }

    func testHousekeeperStillWorksIfNotInIsolationButIsWaitingForExposureApproval() throws {
        let housekeeper = createHouseKeeper(
            isolationLogicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil),
            isWaitingForExposureApproval: true
        )

        _ = housekeeper.executeHousekeeping()

        XCTAssert(deleteExpiredExposureWindowsCalled)
    }
}
