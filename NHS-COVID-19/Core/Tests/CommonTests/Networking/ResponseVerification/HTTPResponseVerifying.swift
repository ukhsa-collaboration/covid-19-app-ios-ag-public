//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Scenarios
import TestSupport
import XCTest
@testable import Common

class HTTPResponseVerifyingTests: XCTestCase {

    private let verifier = MockHTTPResponseVerifier()

    func testSuccessVerificationResult() {
        verifier.shouldConsiderSignatureValid = true
        XCTAssertNoThrow(try verifier.verify(.random(), for: .random()).get())
    }

    func testFailureVerificationResult() {
        verifier.shouldConsiderSignatureValid = false
        XCTAssertThrowsError(try verifier.verify(.random(), for: .random()).get())
    }

}
