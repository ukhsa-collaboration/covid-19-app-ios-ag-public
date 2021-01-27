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
        let request = VirologyTestResultRequest(pollingToken: PollingToken(value: .random()), country: .england)
        
        let expected = HTTPRequest.post("/virology-test/v2/results", body: .json("{\"country\":\"England\",\"testResultPollingToken\":\"\(request.pollingToken.value)\"}"))
        
        let actual = try endpoint.request(for: request)
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingTestResultPositive() throws {
        let date = "2020-04-23T00:00:00.0000000Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .positive, testKitType: .labResult, endDate: try XCTUnwrap(formatter.date(from: date))),
            true
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultNegative() throws {
        let date = "2020-04-23T00:00:00Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE",
            "testKit": "RAPID_RESULT",
            "diagnosisKeySubmissionSupported": true
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .negative, testKitType: .rapidResult, endDate: try XCTUnwrap(formatter.date(from: date))),
            true
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultVoid() throws {
        let date = "2020-04-23T00:00:00Z"
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "VOID",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        let expectedResponse = VirologyTestResponse.receivedResult(
            VirologyTestResult(testResult: .void, testKitType: .labResult, endDate: try XCTUnwrap(formatter.date(from: date))),
            true
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
