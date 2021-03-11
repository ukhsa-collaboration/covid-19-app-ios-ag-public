//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class RiskyVenuesConfigurationEndpointTests: XCTestCase {
    
    private let endpoint = RiskyVenuesConfigurationEndpoint()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/risky-venue-configuration")
        let actual = try endpoint.request(for: ())
        TS.assert(actual, equals: expected)
    }
    
    func testDecoding() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "durationDays": {
                "optionToBookATest": 11
            }
        }
        """#))
        
        let configuration = try endpoint.parse(response)
        let expecteedConfiguration = RiskyVenueConfiguration(optionToBookATest: 11)
        
        XCTAssertEqual(configuration, expecteedConfiguration)
    }
}
