//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest

class UTCHourTests: XCTestCase {

    func testCreatingValidUTCHour() {
        let exitManner = Thread.detachSyncSupervised {
            _ = UTCHour(year: 2020, month: 2, day: 29, hour: 7, minutes: 0)
        }
        TS.assert(exitManner, equals: .normal)
    }

    func testCreatingInvalidUTCHourAsserts() {
        let exitManner = Thread.detachSyncSupervised {
            _ = UTCHour(year: 2020, month: 12, day: 30, hour: 25, minutes: 61)
        }
        TS.assert(exitManner, equals: .assertion)
    }

    func testCreatingUTCHourWithRoundUpTenToFifteen() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 10).date
        let utcHour = UTCHour(roundedUpToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 15)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundUpGranularityFiveToFifteen() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 5).date
        let utcHour = UTCHour(roundedUpToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 15)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundUpGranularityFiftySixToZero() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 56).date
        let utcHour = UTCHour(roundedUpToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 23, minutes: 0)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundUpGranularityFiftySixToZeroNextDayAndMonthAndYear() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 31, hour: 23, minutes: 56).date
        let utcHour = UTCHour(roundedUpToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2021, month: 1, day: 1, hour: 0, minutes: 0)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundDownTenToFifteen() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 10).date
        let utcHour = UTCHour(roundedDownToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 0)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundDownGranularityFiveToZero() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 5).date
        let utcHour = UTCHour(roundedDownToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 0)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testCreatingUTCHourWithRoundDownGranularityFiftySixToFortyFive() {

        let dateFromUtcHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 56).date
        let utcHour = UTCHour(roundedDownToQuarter: dateFromUtcHour)
        let expectedUTCHour = UTCHour(year: 2020, month: 12, day: 22, hour: 22, minutes: 45)

        XCTAssertEqual(utcHour, expectedUTCHour)
    }

    func testIsLaterThanOrEqual() {
        let startHour = UTCHour(year: 2021, month: 04, day: 07, hour: 21, minutes: 00)

        let twentyFiveHoursLater = UTCHour(year: 2021, month: 04, day: 08, hour: 22, minutes: 00)
        XCTAssertTrue(twentyFiveHoursLater.isLaterThanOrEqualTo(hours: 24, after: startHour))

        let twoHoursLater = UTCHour(year: 2021, month: 04, day: 07, hour: 22, minutes: 00)
        XCTAssertFalse(twoHoursLater
            .isLaterThanOrEqualTo(hours: 24, after: startHour))

        XCTAssertFalse(startHour.isLaterThanOrEqualTo(hours: 24, after: twentyFiveHoursLater))

        let twentyFourHoursBefore = UTCHour(year: 2021, month: 04, day: 06, hour: 21, minutes: 00)
        XCTAssertFalse(twentyFourHoursBefore
            .isLaterThanOrEqualTo(hours: 24, after: startHour))
    }
}
