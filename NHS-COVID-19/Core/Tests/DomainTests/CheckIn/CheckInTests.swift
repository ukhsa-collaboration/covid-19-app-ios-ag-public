//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class CheckInTests: XCTestCase {

    func testSortCheckInsBasedOnSeverityLevelAndCheckInDate() {
        let checkIn1 = CheckIn(
            venue: Venue.random(),
            checkedIn: UTCHour(day: GregorianDay.today.advanced(by: -1), hour: 5),
            checkedOut: UTCHour(day: GregorianDay.today.advanced(by: -1), hour: 7),
            isRisky: true
        )
        let checkIn2 = CheckIn(
            venue: Venue.random(),
            checkedIn: UTCHour(day: GregorianDay.today.advanced(by: -2), hour: 5),
            checkedOut: UTCHour(day: GregorianDay.today.advanced(by: -2), hour: 7),
            isRisky: true,
            venueMessageType: .warnAndBookATest
        )
        let checkIn3 = CheckIn(
            venue: Venue.random(),
            checkedIn: UTCHour(day: GregorianDay.today.advanced(by: -2), hour: 5),
            checkedOut: UTCHour(day: GregorianDay.today.advanced(by: -2), hour: 7),
            isRisky: true,
            venueMessageType: .warnAndInform
        )
        let checkIn4 = CheckIn(
            venue: Venue.random(),
            checkedIn: UTCHour(day: GregorianDay.today.advanced(by: -1), hour: 5),
            checkedOut: UTCHour(day: GregorianDay.today.advanced(by: -1), hour: 7),
            isRisky: true,
            venueMessageType: .warnAndBookATest
        )

        let checkIns: [CheckIn] = [checkIn1, checkIn2, checkIn3, checkIn4]

        let sortedCheckIns = checkIns.sorted {
            $0.isMoreRecentAndSevere(than: $1)
        }

        XCTAssertEqual(sortedCheckIns[0], checkIn4)
        XCTAssertEqual(sortedCheckIns[1], checkIn2)
        XCTAssertEqual(sortedCheckIns[2], checkIn3)
        XCTAssertEqual(sortedCheckIns[3], checkIn1)
    }
}
