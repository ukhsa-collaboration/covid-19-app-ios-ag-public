//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class IsolationPaymentTokenCreateEndpointTests: XCTestCase {
    
    private let endpoint = IsolationPaymentTokenCreateEndpoint()
    
    func testEncodingCountryEngland() throws {
        let expected = HTTPRequest.post("/isolation-payment/ipc-token/create", body: .json(#"""
        {
          "country" : "England"
        }
        """#))
            .withCanonicalJSONBody()
        
        let actual = try endpoint.request(for: .england).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingCountryWales() throws {
        let expected = HTTPRequest.post("/isolation-payment/ipc-token/create", body: .json(#"""
        {
          "country" : "Wales"
        }
        """#))
            .withCanonicalJSONBody()
        
        let actual = try endpoint.request(for: .wales).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testDecoding() throws {
        let ipcTokenString = UUID().uuidString
        
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "ipcToken": "\(ipcTokenString)",
                "isEnabled": true
            }
            """)
        )
        
        let expected = IsolationPaymentRawState.ipcToken(ipcTokenString)
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
    
    func testDecodingWithNoToken() {
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "isEnabled": true
            }
            """)
        )
        
        XCTAssertThrowsError(try endpoint.parse(httpResponse))
    }
    
    func testDecodingDiabled() throws {
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "isEnabled": false
            }
            """)
        )
        
        let expected = IsolationPaymentRawState.disabled
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
}
