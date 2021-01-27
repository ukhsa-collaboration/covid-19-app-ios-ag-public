//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class LinkVirologyTestResultEndpointTests: XCTestCase {
    
    private let endpoint = LinkVirologyTestResultEndpoint()
    
    func testEncoding() throws {
        let ctaToken = CTAToken(value: .random(), country: .england)
        
        let countryString: String = {
            switch ctaToken.country {
            case .england: return "England"
            case .wales: return "Wales"
            }
        }()
        
        let expectedRequest = HTTPRequest.post("/virology-test/v2/cta-exchange", body: .json("{\"country\":\"\(countryString)\",\"ctaToken\":\"\(ctaToken.value)\"}"))
        
        let actualRequest = try endpoint.request(for: ctaToken)
        
        TS.assert(actualRequest, equals: expectedRequest)
    }
    
    func testDecodingPositiveLfdDiagnosisKeySubmissionSupported() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : true
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: try XCTUnwrap(formatter.date(from: date))
            ),
            diagnosisKeySubmissionSupport: .supported(diagnosisKeySubmissionToken: submissionToken)
        )
        
        let parsedResponse = try endpoint.parse(actualResponse)
        
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingPositiveLfdDiagnosisKeySubmissionNotSupported() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: try XCTUnwrap(formatter.date(from: date))
            ),
            diagnosisKeySubmissionSupport: .notSupported
        )
        
        let parsedResponse = try endpoint.parse(actualResponse)
        
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingInvalidTestKit() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit" : "Invalid",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false
        }
        """#))
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
    
    func testDecodingLFDInvalidResponseOnVoid() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "VOID",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
    
    func testDecodingLFDInvalidResponseOnNegative() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
}
