//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class RoundingTests: XCTestCase {
    func testRoundingDown() {
        XCTAssertEqual(6, 7.rounded(.down, toNearest: 2))
        XCTAssertEqual(-4, (-3.2).rounded(.down, toNearest: 1))
        XCTAssertEqual(8, 11.3.rounded(.down, toNearest: 4))
        XCTAssertEqual(-12, (-11.3).rounded(.down, toNearest: 2))
        XCTAssertEqual(0, 1.rounded(.down, toNearest: 2))
        XCTAssertTrue(18.rounded(.down, toNearest: 0).isNaN)
    }

    func testRoundingUp() {
        XCTAssertEqual(8, 7.rounded(.up, toNearest: 2))
        XCTAssertEqual(-3, (-3.2).rounded(.up, toNearest: 1))
        XCTAssertEqual(12, 11.3.rounded(.up, toNearest: 4))
        XCTAssertEqual(-10, (-11.3).rounded(.up, toNearest: 2))
        XCTAssertEqual(2, 1.rounded(.up, toNearest: 2))
        XCTAssertTrue(18.rounded(.up, toNearest: 0).isNaN)
    }

    func testRoundingToNearestOrAwayFromZero() {
        XCTAssertEqual(8, 7.rounded(.toNearestOrAwayFromZero, toNearest: 2))
        XCTAssertEqual(-3, (-3.2).rounded(.toNearestOrAwayFromZero, toNearest: 1))
        XCTAssertEqual(12, 11.3.rounded(.toNearestOrAwayFromZero, toNearest: 4))
        XCTAssertEqual(-12, (-11.3).rounded(.toNearestOrAwayFromZero, toNearest: 2))
        XCTAssertEqual(2, 1.rounded(.toNearestOrAwayFromZero, toNearest: 2))
        XCTAssertTrue(18.rounded(.toNearestOrAwayFromZero, toNearest: 0).isNaN)
    }
}
