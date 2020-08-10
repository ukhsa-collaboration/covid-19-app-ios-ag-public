//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class AppAvailabilityEndpointTests: XCTestCase {
    
    private let endpoint = AppAvailabilityEndpoint()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/availability-ios")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecoding() throws {
        let minimumOSVersionDescription = UUID().uuidString
        let minimumAppVersionDescription = UUID().uuidString
        
        let response = HTTPResponse.ok(with: .json("""
        {
          "minimumOSVersion": {
            "value": "13.5.0",
            "description": {
              "en-GB": "\(minimumOSVersionDescription)"
            }
          },
          "minimumAppVersion": {
            "value": "3.0.0",
            "description": {
              "en-GB": "\(minimumAppVersionDescription)"
            }
          },
        }
        """))
        
        let expected = AppAvailability(
            iOSVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 13, minor: 5),
                descriptions: [Locale(identifier: "en-GB"): minimumOSVersionDescription]
            ),
            appVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 3),
                descriptions: [Locale(identifier: "en-GB"): minimumAppVersionDescription]
            )
        )
        
        TS.assert(try endpoint.parse(response), equals: expected)
    }
    
    func testDecodingValueWithMinorAndPatchVersionsOmitted() throws {
        let minimumOSVersionDescription = UUID().uuidString
        let minimumAppVersionDescription = UUID().uuidString
        
        let response = HTTPResponse.ok(with: .json("""
        {
          "minimumOSVersion": {
            "value": "13.5",
            "description": {
              "en-GB": "\(minimumOSVersionDescription)"
            }
          },
          "minimumAppVersion": {
            "value": "3",
            "description": {
              "en-GB": "\(minimumAppVersionDescription)"
            }
          },
        }
        """))
        
        let expected = AppAvailability(
            iOSVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 13, minor: 5),
                descriptions: [Locale(identifier: "en-GB"): minimumOSVersionDescription]
            ),
            appVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 3),
                descriptions: [Locale(identifier: "en-GB"): minimumAppVersionDescription]
            )
        )
        
        TS.assert(try endpoint.parse(response), equals: expected)
    }
    
    func testDecodingValueWithInvalidVersionsFails() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
          "minimumOSVersion": {
            "value": "v13.5",
            "description": {
              "en-GB": ""
            }
          },
          "minimumAppVersion": {
            "value": "3",
            "description": {
              "en-GB": ""
            }
          },
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(response))
    }
}
