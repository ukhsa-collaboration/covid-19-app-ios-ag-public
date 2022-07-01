//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class DateCodingTests: XCTestCase {
    func testEncodingStringToDate() throws {
        let string = """
        "2020-04-23T00:00:00.0000000Z"
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking

        let date = try decoder.decode(Date.self, from: string.data)
        let dateComponents = Calendar.utc.dateComponents([.year, .month, .day], from: date)

        XCTAssertEqual(dateComponents, DateComponents(year: 2020, month: 4, day: 23))
    }

    func testEncodingStringWithoutFractionalSecondsToDate() throws {
        let string = """
        "2020-04-23T00:00:00Z"
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking

        let date = try decoder.decode(Date.self, from: string.data)
        let dateComponents = Calendar.utc.dateComponents([.year, .month, .day], from: date)

        XCTAssertEqual(dateComponents, DateComponents(year: 2020, month: 4, day: 23))
    }
}
