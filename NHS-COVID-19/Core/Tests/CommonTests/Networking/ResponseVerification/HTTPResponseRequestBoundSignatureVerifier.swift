//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import TestSupport
import XCTest
@testable import Common

class HTTPResponseRequestBoundSignatureVerifierTests: XCTestCase {

    private let request = HTTPRequest.post("/activation/request", body: .plain(Data.random()), headers: HTTPHeaders(fields: ["Request-Id": "D96CB6DC-6DE2-4ABF-8FDE-DF1A3D643D94"]))
    private let verifier = HTTPResponseRequestBoundSignatureVerifier(
        key: .sample,
        id: .keyIdentifier
    )

    func testPrepareAddsARequestId() throws {
        let preparedRequest = verifier.prepare(request)

        let id = try XCTUnwrap(preparedRequest.headers.fields[HTTPHeaderFieldName("Request-Id")])
        XCTAssert(!id.isEmpty)
    }

    func testVerifyFailsIfHeaderIsNotSet() {
        let response = HTTPResponse.ok(with: .untyped(.sampleContent))

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyFailsIfHeaderIsMalformed() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(HTTPHeaders.validHeaders) {
                $0.fields[.signature] = .random()
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyFailsIfHeaderPartsHaveIncorrectName() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(HTTPHeaders.validHeaders) {
                $0.fields[.signature] = .signatureHeaderWithMisNamedHeaderParts
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyFailsIfKeyIdIsIncorrect() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(HTTPHeaders.validHeaders) {
                $0.fields[.signature] = .signatureHeaderWithIncorrectKeyId
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyFailsIfSignatureIsMalformed() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(HTTPHeaders.validHeaders) {
                $0.fields[.signature] = .signatureHeaderWithMalformedSignature
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyFailsIfSignatureIsForWrongContent() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.random()),
            headers: .validHeaders
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyDoesNotPassIfDateIsMissing() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(.validHeaders) {
                $0.fields.removeValue(forKey: .signatureDate)
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyDoesNotPassIfDateIsInvalid() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: mutating(.validHeaders) {
                $0.fields[.signatureDate] = .invalidDate
            }
        )

        XCTAssertFalse(verifier.canAccept(response, for: request))
    }

    func testVerifyPassesForCorrectHeader() {
        let response = HTTPResponse(
            statusCode: 200,
            body: .untyped(.sampleContent),
            headers: .validHeaders
        )

        XCTAssert(verifier.canAccept(response, for: request))
    }

}

private extension P256.Signing.PublicKey {

    static let sample = try! P256.Signing.PublicKey(pemRepresentationCompatibility: #"""
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEqCkmIgEk4ojU2yIvejV0uzIroJJC
    SNVxLyo9xDFKiHsnqs7kFu418ynYKTZfx8y42ahiUwKN4Er4KAnFW1LtxA==
    -----END PUBLIC KEY-----
    """#)

}

private extension Data {

    static let sampleContent = Data()

}

private extension HTTPHeaders {

    static let validHeaders = HTTPHeaders(fields: [
        .signatureDate: .validDate,
        .signature: .validSignatureHeader,
    ])

}

private extension HTTPHeaderFieldName {

    static let signature = HTTPHeaderFieldName("x-amz-meta-signature")
    static let signatureDate = HTTPHeaderFieldName("x-amz-meta-signature-date")
    static let requestId = HTTPHeaderFieldName("request-id")

}

private extension String {

    static let keyIdentifier = "b4c27bf3-8a76-4d2b-b91c-2152e7710a57"

    static let validDate = "Sun, 02 Aug 2020 18:13:05 UTC"

    static let invalidDate = "Sun, 02 Aug 2020 15:11:00 UTC"

    static let validSignatureHeader = #"""
    keyId="b4c27bf3-8a76-4d2b-b91c-2152e7710a57",signature="MEUCIHK7mz1iDZBuMyVOGDniAmx1/UxJPaRcJDxKqkjOQSCiAiEAoaS41mzMtjqe8lz/skejpsvJ9IdgLi7VUr2U8tla5vY="
    """#

    static let signatureHeaderWithIncorrectKeyId = #"""
    keyId="not-my-key",signature="MEUCIQCCKbkfx8XundFbI8oQJmD11qIjsNUqYbybSNKn5mt3bQIgDJAbpXxgBO0YIPHoRMNlUxBcimd28znJoKF/YQBDUaM="
    """#

    static let signatureHeaderWithMalformedSignature = #"""
    keyId="b4c27bf3-8a76-4d2b-b91c-2152e7710a57",signature="not-a-sig"
    """#

    static let signatureHeaderWithMisNamedHeaderParts = #"""
    notKeyId="b4c27bf3-8a76-4d2b-b91c-2152e7710a57",signature="MEUCIQCCKbkfx8XundFbI8oQJmD11qIjsNUqYbybSNKn5mt3bQIgDJAbpXxgBO0YIPHoRMNlUxBcimd28znJoKF/YQBDUaM="
    """#
}
