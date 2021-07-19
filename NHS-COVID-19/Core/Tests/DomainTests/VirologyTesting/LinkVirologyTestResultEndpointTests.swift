//
// Copyright © 2021 DHSC. All rights reserved.
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
            "diagnosisKeySubmissionSupported" : true,
            "requiresConfirmatoryTest": false
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
            diagnosisKeySubmissionSupport: .supported(diagnosisKeySubmissionToken: submissionToken),
            requiresConfirmatoryTest: false
        )
        
        let parsedResponse = try endpoint.parse(actualResponse)
        
        TS.assert(parsedResponse, equals: expectedResponse)
    }
    
    func testDecodingUnconfirmedWithKeyShareSupport() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : true,
            "requiresConfirmatoryTest": true
        }
        """#))
        
        let expectedResponse = LinkVirologyTestResultResponse(
            virologyTestResult: .init(
                testResult: .positive,
                testKitType: .rapidResult,
                endDate: DateComponents(
                    calendar: .current,
                    timeZone: .utc,
                    year: 2021,
                    month: 1,
                    day: 10
                ).date!
            ),
            diagnosisKeySubmissionSupport: .supported(diagnosisKeySubmissionToken: submissionToken),
            requiresConfirmatoryTest: true
        )
        
        TS.assert(try endpoint.parse(actualResponse), equals: expectedResponse)
    }
    
    func testDecodingUnconfirmedTestWithNegativeResult() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE",
            "testKit" : "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
    
    func testDecodingTestWithPLODResult() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "PLOD",
            "testKit" : "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": false
        }
        """#))
        
        XCTAssertNoThrow(try endpoint.parse(actualResponse))
    }
    
    func testDecodingUnconfirmedTestWithVoidResult() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "VOID",
            "testKit" : "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
    
    func testDecodingTestWithUnknownResult() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "UNKNOWN_TEST_RESULT_TYPE",
            "testKit" : "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": false
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse)) { error in
            switch error {
            case DecodingError.dataCorrupted:
                break
            default:
                XCTFail()
            }
        }
    }
    
    func testDecodingPositiveLfdDiagnosisKeySubmissionNotSupported() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
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
            diagnosisKeySubmissionSupport: .notSupported,
            requiresConfirmatoryTest: true
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
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
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
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": false
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
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse))
    }
    
    func testDecodingInvalidVenueSharingResponse() throws {
        let date = "2021-01-10T00:00:00.0000000Z"
        
        let actualResponse = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "NEGATIVE",
            "testKit" : "RAPID_RESULT",
            "diagnosisKeySubmissionToken": null,
            "diagnosisKeySubmissionSupported" : false,
            "requiresConfirmatoryTest": true
        }
        """#))
        
        XCTAssertThrowsError(try endpoint.parse(actualResponse)) // expecting a venue sharing token
    }
    
}
