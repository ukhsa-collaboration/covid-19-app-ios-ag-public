//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class VirologyTestResultEndpointTests: XCTestCase {
    
    private let endpoint = VirologyTestResultEndpoint()
    
    func testEndpoint() throws {
        let pollingToken = PollingToken(value: .random())
        
        let expected = HTTPRequest.post("/virology-test/results", body: .json("{\"testResultPollingToken\":\"\(pollingToken.value)\"}"))
        
        let actual = try endpoint.request(for: pollingToken)
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingTestResultPositive() throws {
        let date = "2020-04-23T00:00:00.0000000Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE"
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withFractionalSeconds
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .positive, endDate: try XCTUnwrap(formatter.date(from: date)))
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultNegative() throws {
        let date = "2020-04-23T00:00:00Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE"
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .negative, endDate: try XCTUnwrap(formatter.date(from: date)))
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultVoid() throws {
        let date = "2020-04-23T00:00:00Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "VOID"
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .void, endDate: try XCTUnwrap(formatter.date(from: date)))
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingNoResultYet() throws {
        let response = HTTPResponse.noContent(with: .empty)
        
        let expectedResponse = VirologyTestResponse.noResultYet
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
}
