//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

class LocaleIdentifierTests: XCTestCase {
    func testBasic() throws {
        let en = LocaleIdentifier(rawValue: "en")
        XCTAssertEqual(en.rawValue, "en")
        XCTAssertEqual(en.canonicalValue, "en")
        XCTAssertEqual(en.languageCode, "en")
    }

    func testWithUnderscore() throws {
        let en = LocaleIdentifier(rawValue: "en_GB")
        XCTAssertEqual(en.rawValue, "en_GB")
        XCTAssertEqual(en.canonicalValue, "en-gb")
        XCTAssertEqual(en.languageCode, "en")
    }

    func testWithDash() throws {
        let en = LocaleIdentifier(rawValue: "en-GB")
        XCTAssertEqual(en.rawValue, "en-GB")
        XCTAssertEqual(en.canonicalValue, "en-gb")
        XCTAssertEqual(en.languageCode, "en")
    }
}
