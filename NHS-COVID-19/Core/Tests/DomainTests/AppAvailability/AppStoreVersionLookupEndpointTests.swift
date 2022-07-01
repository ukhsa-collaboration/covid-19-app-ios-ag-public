//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class AppStoreVersionLookupEndpointTests: XCTestCase {

    private let endpoint = AppStoreVersionLookupEndpoint(bundleId: .random())

    func testEncoding() throws {
        let expected = HTTPRequest.get("/lookup", queryParameters: ["bundleId": endpoint.bundleId])

        let actual = try endpoint.request(for: ())

        TS.assert(actual, equals: expected)
    }

    func testDecoding() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "results": [
                {
                    "bundleId": "\#(endpoint.bundleId)",
                    "version": "3.0.1"
                }
            ]
        }
        """#))

        let expected = Version(major: 3, patch: 1)

        TS.assert(try endpoint.parse(response), equals: expected)
    }

    func testDecodingChoosesTheRightApp() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "results": [
                {
                    "bundleId": "wrong",
                    "version": "1.0.1"
                },
                {
                    "bundleId": "\#(endpoint.bundleId)",
                    "version": "2.0.1"
                },
                {
                    "bundleId": "also-wrong",
                    "version": "3.0.1"
                },
            ]
        }
        """#))

        let expected = Version(major: 2, patch: 1)

        TS.assert(try endpoint.parse(response), equals: expected)
    }

    func testDecodingToleratesNonSemanticVersionOnOtherApps() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "results": [
                {
                    "bundleId": "\#(endpoint.bundleId)",
                    "version": "2.0.1"
                },
                {
                    "bundleId": "also-wrong",
                    "version": "notSemVer"
                },
            ]
        }
        """#))

        let expected = Version(major: 2, patch: 1)

        TS.assert(try endpoint.parse(response), equals: expected)
    }

    func testDecodingThrowsIfCanNotFindApp() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "results": [
                {
                    "bundleId": "wrong",
                    "version": "1.0.1"
                },
                {
                    "bundleId": "also-wrong",
                    "version": "3.0.1"
                },
            ]
        }
        """#))

        XCTAssertThrowsError(try endpoint.parse(response))
    }

}
