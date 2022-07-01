//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class IncrementTests: XCTestCase {
    func testIncrementChangeFromDailytoTwoHourly() throws {
        let lastCheckDate = try XCTUnwrap(Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7)))
        let now = try XCTUnwrap(Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 9)))

        let (firstIncrement, checkDate) = try XCTUnwrap(Increment.nextIncrement(lastCheckDate: lastCheckDate, now: now))

        switch firstIncrement {
        case .daily(let day):
            XCTAssertEqual(day.year, 2020)
            XCTAssertEqual(day.month, 5)
            XCTAssertEqual(day.day, 8)
        case .twoHourly:
            XCTFail()
        }

        let (secondIncrement, _) = try XCTUnwrap(Increment.nextIncrement(lastCheckDate: checkDate, now: now))

        switch secondIncrement {
        case .daily:
            XCTFail()
        case .twoHourly(let day, let twoHour):
            XCTAssertEqual(day.year, 2020)
            XCTAssertEqual(day.month, 5)
            XCTAssertEqual(day.day, 8)
            XCTAssertEqual(twoHour.value, 2)
        }
    }

    func testNextIncrementBecomesNilPastNow() throws {
        let lastCheckDate = try XCTUnwrap(Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 9, hour: 2)))
        let now = try XCTUnwrap(Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 9, hour: 4)))

        let (increment, checkDate) = try XCTUnwrap(Increment.nextIncrement(lastCheckDate: lastCheckDate, now: now))

        switch increment {
        case .daily:
            XCTFail()
        case .twoHourly(let day, let twoHour):
            XCTAssertEqual(day.year, 2020)
            XCTAssertEqual(day.month, 5)
            XCTAssertEqual(day.day, 9)
            XCTAssertEqual(twoHour.value, 4)
        }

        XCTAssertNil(Increment.nextIncrement(lastCheckDate: checkDate, now: now))
    }
}
