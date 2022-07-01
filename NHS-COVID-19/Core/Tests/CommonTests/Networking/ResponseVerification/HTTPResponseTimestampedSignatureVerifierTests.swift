//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import TestSupport
import XCTest
@testable import Common

class HTTPResponseTimestampedSignatureVerifierTests: XCTestCase {

    private let request = HTTPRequest.post("/\(String.random())", body: .plain(Data.random()))
    private let verifier = HTTPResponseTimestampedSignatureVerifier(key: .sample, id: .keyIdentifier)

    func testPrepareRequestLeavesItUntouched() {

        TS.assert(request, equals: verifier.prepare(request))
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
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE4hMkTF8BMF2iMjaCrNfnGbGUQqaz
    Ap8nRyuwyJRpoetrq8XeoCe1sHSdvV3Ncvpi99KPkEPf3MiR8MkRPqzAig==
    -----END PUBLIC KEY-----
    """#)

}

private extension Data {

    static let sampleContent = Data(base64Encoded: """
    ewogICJtaW5pbXVtT1NWZXJzaW9uIjogewogICAgInZhbHVlIjogIjEzLjUuMCIsCiAgICAiZGVzY3JpcHRpb24iOiB7CiAgICAgICJlbi1HQiI6ICIiCiAgICB9CiAgfSwKICAibWluaW11bUFwcFZlcnNpb24iOiB7CiAgICAidmFsdWUiOiAiMy4wLjAiLAogICAgImRlc2NyaXB0aW9uIjogewogICAgICAiZW4tR0IiOiAiIgogICAgfQogIH0KfQ==
    """)!

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

    static let keyIdentifier = "cde235d2-4f11-4368-8e67-6074560f9816"

    static let validDate = "Mon, 03 Aug 2020 22:59:35 UTC"

    static let invalidDate = "Sun, 02 Aug 2020 15:11:00 UTC"

    static let validSignatureHeader = #"""
    keyId="cde235d2-4f11-4368-8e67-6074560f9816",signature="MEQCIH/rtzf39sDhGmziL/i9TrtbP0jm+e49X57/vGwPhFd8AiBFLPH2DDw0gHqt9x0b85XQ8SOBdoHY7i1VwaqzZ1eZaw=="
    """#

    static let signatureHeaderWithIncorrectKeyId = #"""
    keyId="not-my-key",signature="MEQCIH/rtzf39sDhGmziL/i9TrtbP0jm+e49X57/vGwPhFd8AiBFLPH2DDw0gHqt9x0b85XQ8SOBdoHY7i1VwaqzZ1eZaw=="
    """#

    static let signatureHeaderWithMalformedSignature = #"""
    keyId="b4c27bf3-8a76-4d2b-b91c-2152e7710a57",signature="not-a-sig"
    """#

    static let signatureHeaderWithMisNamedHeaderParts = #"""
    notKeyId="cde235d2-4f11-4368-8e67-6074560f9816",signature="MEQCIH/rtzf39sDhGmziL/i9TrtbP0jm+e49X57/vGwPhFd8AiBFLPH2DDw0gHqt9x0b85XQ8SOBdoHY7i1VwaqzZ1eZaw=="
    """#

}
