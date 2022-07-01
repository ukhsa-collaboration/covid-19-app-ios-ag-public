//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import TestSupport
import XCTest
@testable import Common

class P256SigningPublicKeyTests: XCTestCase {

    func testCreatingKeyFromValidPEM() {
        XCTAssertNoThrow(try P256.Signing.PublicKey(pemRepresentationCompatibility: .validPEM))
    }

    func testCreatingKeyFromInvalidPEM() {
        XCTAssertThrowsError(try P256.Signing.PublicKey(pemRepresentationCompatibility: .invalidPEM))
    }

}

private extension String {

    static let validPEM = #"""
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEqCkmIgEk4ojU2yIvejV0uzIroJJC
    SNVxLyo9xDFKiHsnqs7kFu418ynYKTZfx8y42ahiUwKN4Er4KAnFW1LtxA==
    -----END PUBLIC KEY-----
    """#

    static let invalidPEM = #"""
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEqCkmIgEk4ojU2yIvejV0uzIroJJC
    """#

}
