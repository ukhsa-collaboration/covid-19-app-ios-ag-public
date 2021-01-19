//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Common

class LocaleStringTests: XCTestCase {
    func testLocaleStringDecoding() throws {
        let locale = String.random()
        let value = String.random()
        
        let data = """
        {
            "\(locale)": "\(value)"
        }
        """.data(using: .utf8)!
        
        let localeString = try JSONDecoder().decode(LocaleString.self, from: data)
        
        XCTAssertFalse(localeString.isEmpty)
        XCTAssertEqual(localeString[Locale(identifier: locale)], value)
    }
}
