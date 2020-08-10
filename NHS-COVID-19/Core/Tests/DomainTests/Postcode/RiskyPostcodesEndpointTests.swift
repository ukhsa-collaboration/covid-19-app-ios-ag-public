//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class RiskyPostcodesEndpointTests: XCTestCase {
    
    private let endpoint = RiskyPostcodesEndpoint()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/risky-post-districts")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "postDistricts" : {}
        }
        """#))
        
        let postcodes = try endpoint.parse(response)
        
        XCTAssert(postcodes.isEmpty)
    }
    
    func testDecodingListWithPostcodes() throws {
        let postcode1 = String.random()
        let postcode2 = String.random()
        let postcode3 = String.random()
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "postDistricts" : {
                "\#(postcode1)": "H",
                "\#(postcode2)": "M",
                "\#(postcode3)": "L",
            }
        }
        """#))
        
        let postcodes = try endpoint.parse(response)
        
        TS.assert(postcodes, equals: [postcode1: PostcodeRisk.high, postcode2: PostcodeRisk.medium, postcode3: PostcodeRisk.low])
    }
    
}
