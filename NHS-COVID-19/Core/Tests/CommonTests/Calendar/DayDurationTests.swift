//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest

class DayDurationTests: XCTestCase {

    func testAddingIsolationDurationToGregorianDayTicksOverMonth() {
        let day = GregorianDay(year: 2020, month: 2, day: 29)
        let newDay = day + DayDuration(7)
        TS.assert(newDay, equals: GregorianDay(year: 2020, month: 3, day: 7))
    }

    func testAddingIsolationDurationToGregorianDayTicksOverYear() {
        let day = GregorianDay(year: 2020, month: 12, day: 31)
        let newDay = day + DayDuration(7)
        TS.assert(newDay, equals: GregorianDay(year: 2021, month: 1, day: 7))
    }
}
