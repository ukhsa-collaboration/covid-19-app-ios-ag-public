//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import TestSupport
import XCTest
@testable import Domain

class PostcodeTests: XCTestCase {

    // MARK: - Codable

    func testDecodingLowercased() throws {
        let json = """
        "ab12"
        """.data(using: .utf8)!
        let actual = try JSONDecoder().decode(Postcode.self, from: json)
        TS.assert(actual, equals: Postcode("AB12"))
    }

    func testDecodingUppercased() throws {
        let json = """
        "AB12"
        """.data(using: .utf8)!
        let actual = try JSONDecoder().decode(Postcode.self, from: json)
        TS.assert(actual, equals: Postcode("AB12"))
    }

    func testEncoding() throws {
        let json = """
        "AB12"
        """.data(using: .utf8)!
        let actual = try JSONEncoder().encode(Postcode("ab12"))
        TS.assert(actual, equals: json)
    }

    // MARK: - Equatable

    func testPostcodeComparisonIsCaseInsensitive() {
        TS.assert(Postcode("ab12"), equals: Postcode("AB12"))
    }

}
