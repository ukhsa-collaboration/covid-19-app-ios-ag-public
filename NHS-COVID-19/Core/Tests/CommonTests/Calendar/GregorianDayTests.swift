//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest

class GregorianDayTests: XCTestCase {

    func testCreatingValidGregorianDay() {
        let exitManner = Thread.detachSyncSupervised {
            _ = GregorianDay(year: 2020, month: 2, day: 29)
        }
        TS.assert(exitManner, equals: .normal)
    }

    func testCreatingInvalidGregorianDateAsserts() {
        let exitManner = Thread.detachSyncSupervised {
            _ = GregorianDay(year: 2020, month: 0, day: 0)
        }
        TS.assert(exitManner, equals: .assertion)
    }

    func testAdvancingGregorianDayTicksOverMonth() {
        let day = GregorianDay(year: 2020, month: 2, day: 29)
        let newDay = day.advanced(by: 7)
        TS.assert(newDay, equals: GregorianDay(year: 2020, month: 3, day: 7))
    }

    func testAdvancingGregorianDayTicksOverYear() {
        let day = GregorianDay(year: 2020, month: 12, day: 31)
        let newDay = day.advanced(by: 7)
        TS.assert(newDay, equals: GregorianDay(year: 2021, month: 1, day: 7))
    }

    func testGettingDistanceBetweenGregorianDays() {
        let day = GregorianDay(year: 2020, month: 12, day: 31)
        let newDay = GregorianDay(year: 2021, month: 1, day: 7)
        TS.assert(day.distance(to: newDay), equals: 7)
    }

    func testGettingDistanceBetweenDistantDays() {
        let day = GregorianDay(year: 2020, month: 1, day: 31)
        let newDay = GregorianDay(year: 2021, month: 12, day: 7)
        TS.assert(day.distance(to: newDay), equals: 676)
    }

}
