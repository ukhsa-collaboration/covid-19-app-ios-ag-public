//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class LinkVirologyTestResultEndpointTests: XCTestCase {
    
    private let endpoint = LinkVirologyTestResultEndpoint()
    
    func testEndpoint() throws {
        let ctaToken = CTAToken(value: .random())
        
        let expected = HTTPRequest.post("/virology-test/cta-exchange", body: .json("{\"ctaToken\":\"\(ctaToken.value)\"}"))
        
        let actual = try endpoint.request(for: ctaToken)
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingTestResultPositive() throws {
        let date = "2020-04-23T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(testResult: .positive, endDate: try XCTUnwrap(formatter.date(from: date))),
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultNegative() throws {
        let date = "2020-04-23T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(testResult: .negative, endDate: try XCTUnwrap(formatter.date(from: date))),
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingTestResultVoid() throws {
        let date = "2020-04-23T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "VOID",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(testResult: .void, endDate: try XCTUnwrap(formatter.date(from: date))),
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let parsedResponse = try endpoint.parse(response)
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
}
