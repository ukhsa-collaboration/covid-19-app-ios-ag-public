//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class AppActivationEndpointTests: XCTestCase {
    
    private let endpoint = AppActivationEndpoint()
    
    func testEncoding() throws {
        let code = String.random()
        
        let expected = HTTPRequest.post("/activation/request", body: .json(#"""
        {
          "activationCode" : "\#(code)"
        }
        """#))
        
        let actual = try endpoint.request(for: code).withCanonicalJSONBody()
        
        TS.assert(actual, equals: expected)
    }
    
}
