//
// Copyright © 2021 DHSC. All rights reserved.
//

import CryptoKit
import TestSupport
import XCTest
@testable import Domain

// To generate a new payload:
// 1. go to jwt.io
// 2. Paste in an existing payload from below from after the 'UKC19TRACING:1:' to the end of the string
// 3. The Header should be { "alg": "ES256", "typ": "JWT", "kid": "3" }
// 4. Edit the Payload JSON
// 5. Use the default public/private key pair to generate a new encoded jwt

private extension P256.Signing.PublicKey {

    static let testKey = try! P256.Signing.PublicKey(pemRepresentationCompatibility: """
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9
    q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==
    -----END PUBLIC KEY-----
    """)

}

extension VenueDecoder {

    static let forTests = VenueDecoder(keyId: "3", key: .testKey)

}

class VenueDecoderTests: XCTestCase {

    private let decoder = VenueDecoder.forTests

    func testValidQRCode() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
        let venue = Venue(
            id: "4WT59M5Y",
            organisation: "Government Office Of Human Resources"
        )
        TS.assert(try decoder.decode(payload), equals: [venue])
    }

    func testValidQRCodeWithPostcode() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIiwicGMiOiJDTTEifQ.cGzgB0sBV6c9A5LMHgO56SECqPILnCELlr4731iCyJxKFYPrr4a5R5B_wAbkluoJHfSRX7iwbZrJdWbt4z3feA"
        let venue = Venue(
            id: "4WT59M5Y",
            organisation: "Government Office Of Human Resources",
            postcode: "CM1"
        )
        TS.assert(try decoder.decode(payload), equals: [venue])
    }

    func testFutureVersionsAreAllowed() {
        let payload = "UKC19TRACING:2:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
        XCTAssertNoThrow(try decoder.decode(payload))
    }

    func testInvalidQRCodeWithRedundantSegments() throws {
        let payload = "UKC19TRACING:1:2:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidFormat)
        }
    }

    func testQRCodeWithInvalidPrefix() {
        let payload = "DEC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidPrefix)
        }
    }

    func testInvalidQRCodeWithoutPrefix() throws {
        let payload = "1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidFormat)
        }
    }

    func testQRCodeWithVersionZero() {
        let payload = "UKC19TRACING:0:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidVersionNumber)
        }
    }

    func testQRCodeWithEmptyVersion() {
        let payload = "UKC19TRACING::eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidFormat)
        }
    }

    func testQRCodeWithInvalidVersion() {
        let payload = "UKC19TRACING:Z:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidVersionNumber)
        }
    }

    func testInvalidQRCodeWithoutVersion() throws {
        let payload = "UKC19TRACING:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidFormat)
        }
    }

    func testQRCodeWithInvalidKeyIsRejected() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Im5vdC1teS1rZXkifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.B5zt7ZOZ-SzoR2wqaGHJ4GJrTuJuuFXTznAPnMN9Z5NNkJmI6fyYIokCLPdYwWowqZrvfO4O8pqR-BWoQyjAzA"
        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidKey)
        }
    }

    func testQRCodeWithInvalidSignatureIsRejected() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiTXkgR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZX2PHtcxFmNwyrHRIbtcQCAHdhwUTb1h1GqVTNqAK7WiE_qO1nbJVU3BWvRu15DR6WBF14MN1I8yC6B1uK7ghg"
        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidSignature)
        }
    }

    func testInvalidQRCodeWithNonBase64EncodedPayload() throws {
        let payload = "UKC19TRACING:1:$§fg§:"

        XCTAssertThrowsError(try decoder.decode(payload)) {
            self.assertError($0, expectedError: VenueDecoder.InitializationError.invalidJSONData)
        }
    }

    private func assertError(_ rawError: Error, expectedError: VenueDecoder.InitializationError) {
        guard let error = rawError as? VenueDecoder.InitializationError else {
            XCTFail("not a QRCodeDecoder error \(rawError)")
            return
        }

        XCTAssertEqual(error, expectedError)
    }
}
