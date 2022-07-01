//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import Common

class LocaleURLTests: XCTestCase {
    func testLocaleURLDecoding() throws {
        let locale = String.random()
        let value = URL.random()

        let data = """
        {
            "\(locale)": "\(value.absoluteString)"
        }
        """.data(using: .utf8)!

        let localeString = try JSONDecoder().decode(LocaleURL.self, from: data)

        XCTAssertFalse(localeString.isEmpty)
        XCTAssertEqual(localeString[Locale(identifier: locale)], value)
    }

    func testLocaleURLInvalidDecoding() throws {
        let locale = String.random()
        let value = String.random()

        let data = """
        {
            "\(locale)": "\(value)"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(LocaleURL.self, from: data))
    }
}
