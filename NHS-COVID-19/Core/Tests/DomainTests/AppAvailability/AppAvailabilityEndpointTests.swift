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
        let recommendedOSVersionTitle = UUID().uuidString
        let recommendedOSVersionDescription = UUID().uuidString
        let minimumAppVersionDescription = UUID().uuidString
        let recommendedAppVersionTitle = UUID().uuidString
        let recommendedAppVersionDescription = UUID().uuidString
        
        let response = HTTPResponse.ok(with: .json("""
        {
          "minimumOSVersion": {
            "value": "13.5.0",
            "description": {
              "en-GB": "\(minimumOSVersionDescription)"
            }
          },
          "recommendedOSVersion": {
            "value": "13.5.0",
            "title": {
              "en-GB": "\(recommendedOSVersionTitle)"
            },
            "description": {
              "en-GB": "\(recommendedOSVersionDescription)"
            }
          },
          "minimumAppVersion": {
            "value": "3.0.0",
            "description": {
              "en-GB": "\(minimumAppVersionDescription)"
            }
          },
          "recommendedAppVersion": {
            "value": "2.9.0",
            "title": {
              "en-GB": "\(recommendedAppVersionTitle)"
            },
            "description": {
              "en-GB": "\(recommendedAppVersionDescription)"
            }
          },
        }
        """))
        
        let expected = AppAvailability(
            iOSVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 13, minor: 5),
                descriptions: [Locale(identifier: "en-GB"): minimumOSVersionDescription]
            ),
            recommendediOSVersion: AppAvailability.RecommendationRequirement(
                minimumRecommended: Version(major: 13, minor: 5),
                titles: [Locale(identifier: "en-GB"): recommendedOSVersionTitle],
                descriptions: [Locale(identifier: "en-GB"): recommendedOSVersionDescription]
            ),
            appVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 3),
                descriptions: [Locale(identifier: "en-GB"): minimumAppVersionDescription]
            ),
            recommendedAppVersion: AppAvailability.RecommendationRequirement(
                minimumRecommended: Version(major: 2, minor: 9),
                titles: [Locale(identifier: "en-GB"): recommendedAppVersionTitle],
                descriptions: [Locale(identifier: "en-GB"): recommendedAppVersionDescription]
            )
        )
        
        TS.assert(try endpoint.parse(response), equals: expected)
    }
    
    func testDecodingValueWithMinorAndPatchVersionsOmitted() throws {
        let minimumOSVersionDescription = UUID().uuidString
        let recommendedOSVersionTitle = UUID().uuidString
        let recommendedOSVersionDescription = UUID().uuidString
        let minimumAppVersionDescription = UUID().uuidString
        let recommendedAppVersionTitle = UUID().uuidString
        let recommendedAppVersionDescription = UUID().uuidString
        
        let response = HTTPResponse.ok(with: .json("""
        {
          "minimumOSVersion": {
            "value": "13.5",
            "description": {
              "en-GB": "\(minimumOSVersionDescription)"
            }
          },
          "recommendedOSVersion": {
            "value": "13.5",
            "title": {
              "en-GB": "\(recommendedOSVersionTitle)"
            },
            "description": {
              "en-GB": "\(recommendedOSVersionDescription)"
            }
          },
          "minimumAppVersion": {
            "value": "3",
            "description": {
              "en-GB": "\(minimumAppVersionDescription)"
            }
          },
          "recommendedAppVersion": {
            "value": "2.9",
            "title": {
              "en-GB": "\(recommendedAppVersionTitle)"
            },
            "description": {
              "en-GB": "\(recommendedAppVersionDescription)"
            }
          },
        }
        """))
        
        let expected = AppAvailability(
            iOSVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 13, minor: 5),
                descriptions: [Locale(identifier: "en-GB"): minimumOSVersionDescription]
            ),
            recommendediOSVersion: AppAvailability.RecommendationRequirement(
                minimumRecommended: Version(major: 13, minor: 5),
                titles: [Locale(identifier: "en-GB"): recommendedOSVersionTitle],
                descriptions: [Locale(identifier: "en-GB"): recommendedOSVersionDescription]
            ),
            appVersion: AppAvailability.VersionRequirement(
                minimumSupported: Version(major: 3),
                descriptions: [Locale(identifier: "en-GB"): minimumAppVersionDescription]
            ),
            recommendedAppVersion: AppAvailability.RecommendationRequirement(
                minimumRecommended: Version(major: 2, minor: 9),
                titles: [Locale(identifier: "en-GB"): recommendedAppVersionTitle],
                descriptions: [Locale(identifier: "en-GB"): recommendedAppVersionDescription]
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
