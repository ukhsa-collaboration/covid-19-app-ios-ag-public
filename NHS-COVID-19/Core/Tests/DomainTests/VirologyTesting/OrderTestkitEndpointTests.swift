//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class OrderTestkitEndpointTests: XCTestCase {
    
    private let endpoint = OrderTestKitEndpoint()
    
    func testEndpoint() throws {
        let expected = HTTPRequest.post("/virology-test/v2/order", body: .plain(""))
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let expectedResponse = OrderTestkitResponse(
            testOrderWebsite: .random(),
            referenceCode: ReferenceCode(value: .random()),
            testResultPollingToken: PollingToken(value: .random()),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())
        )
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "websiteUrlWithQuery": "\#(expectedResponse.testOrderWebsite.absoluteString)",
            "tokenParameterValue": "\#(expectedResponse.referenceCode.value)",
            "testResultPollingToken" : "\#(expectedResponse.testResultPollingToken.value)",
            "diagnosisKeySubmissionToken": "\#(expectedResponse.diagnosisKeySubmissionToken.value)"
        }
        """#))
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
}
