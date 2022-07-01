//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import TestSupport
import XCTest
@testable import Common

class HTTPHeadersObfuscatorTests: XCTestCase {
    private let request = HTTPRequest.random()
    private let obfuscator = HTTPHeadersObfuscator()

    func testRandomHeaderFieldsSize() {
        let randomSizes = obfuscator.randomHeaderFieldsSize(from: 5000)
        XCTAssertEqual(randomSizes, [2000, 2000, 1000])
        let randomSizes2 = obfuscator.randomHeaderFieldsSize(from: 4000)
        XCTAssertEqual(randomSizes2, [2000, 2000])
        let randomSizes3 = obfuscator.randomHeaderFieldsSize(from: 0)
        XCTAssertEqual(randomSizes3, [])
    }

    func testRandomHeaderBytes() {
        let randomString = obfuscator.randomized(index: 1, bytes: 2000).first!.1
        XCTAssertEqual(randomString.lengthOfBytes(using: .utf8), 2000)
        let randomString2 = obfuscator.randomized(index: 1, bytes: 3000).first!.1
        XCTAssertEqual(randomString2.lengthOfBytes(using: .utf8), 3000)
        let randomString3 = obfuscator.randomized(index: 1, bytes: 1000).first!.1
        XCTAssertEqual(randomString3.lengthOfBytes(using: .utf8), 1000)
    }
}
