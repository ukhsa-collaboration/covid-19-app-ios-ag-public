//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain
@testable import Scenarios

class KeySharingHouseKeeperTests: XCTestCase {

    let store = KeySharingStore(store: MockEncryptedStore())

    private func createHouseKeeper(onsetDay: GregorianDay?, testAcknowledgmentDate: GregorianDay?) -> KeySharingContext {
        if let date = testAcknowledgmentDate {
            let utcHour = UTCHour(day: date, hour: 5)
            store.save(token: DiagnosisKeySubmissionToken(value: .random()), acknowledgmentTime: utcHour)
        }

        return KeySharingContext(
            currentDateProvider: MockDateProvider(),
            contactCaseIsolationDuration: 11,
            onsetDay: { onsetDay },
            keySharingStore: store,
            userNotificationManager: MockUserNotificationsManager()
        )
    }

    func testExecuteTestAcknowledgmentDateValidDateRange() {
        let housekeeper = createHouseKeeper(
            onsetDay: GregorianDay.today.advanced(by: -11),
            testAcknowledgmentDate: GregorianDay.today.advanced(by: -9)
        )

        _ = housekeeper.executeHouseKeeper()
        XCTAssertNotNil(store.info)
    }

    func testExecuteOnsetDayNotAvailable() {
        let housekeeper = createHouseKeeper(
            onsetDay: nil,
            testAcknowledgmentDate: nil
        )

        _ = housekeeper.executeHouseKeeper()
        XCTAssertNil(store.info.currentValue)
    }

    func testExecuteTestAcknowledgmentDateNotAvailable() {
        let housekeeper = createHouseKeeper(
            onsetDay: GregorianDay.today,
            testAcknowledgmentDate: nil
        )

        _ = housekeeper.executeHouseKeeper()
        XCTAssertNil(store.info.currentValue)
    }

    func testExecuteTestAcknowledgmentDateWithExpiredDateRange() {
        let housekeeper = createHouseKeeper(
            onsetDay: GregorianDay.today.advanced(by: -18),
            testAcknowledgmentDate: GregorianDay.today.advanced(by: -9)
        )

        _ = housekeeper.executeHouseKeeper()
        XCTAssertNil(store.info.currentValue)
    }

    func testExecuteTestAcknowledgmentDateWithVeryNewDateRange() {
        let housekeeper = createHouseKeeper(
            onsetDay: GregorianDay.today.advanced(by: -2),
            testAcknowledgmentDate: GregorianDay.today
        )

        _ = housekeeper.executeHouseKeeper()
        XCTAssertNotNil(store.info.currentValue)
    }

}
