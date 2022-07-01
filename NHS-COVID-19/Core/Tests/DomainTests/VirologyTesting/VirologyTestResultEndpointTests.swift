//
// Copyright © 2021 DHSC. All rights reserved.
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
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let expectedResponse = VirologyTestResponse.receivedResult(
            PollVirologyTestResultResponse(
                virologyTestResult: VirologyTestResult(testResult: .positive, testKitType: .labResult, endDate: try XCTUnwrap(formatter.date(from: date))),
                diagnosisKeySubmissionSupport: true,
                requiresConfirmatoryTest: false,
                shouldOfferFollowUpTest: false
            )
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
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        let formatter = ISO8601DateFormatter()

        let expectedResponse = VirologyTestResponse.receivedResult(
            PollVirologyTestResultResponse(
                virologyTestResult: VirologyTestResult(testResult: .negative, testKitType: .labResult, endDate: try XCTUnwrap(formatter.date(from: date))),
                diagnosisKeySubmissionSupport: true,
                requiresConfirmatoryTest: false,
                shouldOfferFollowUpTest: false
            )
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
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        let formatter = ISO8601DateFormatter()

        let expectedResponse = VirologyTestResponse.receivedResult(
            PollVirologyTestResultResponse(
                virologyTestResult: VirologyTestResult(testResult: .void, testKitType: .labResult, endDate: try XCTUnwrap(formatter.date(from: date))),
                diagnosisKeySubmissionSupport: true,
                requiresConfirmatoryTest: false,
                shouldOfferFollowUpTest: false
            )
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

    func testDecodingNegativeRapidTestResult() throws {

        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00Z",
            "testResult": "NEGATIVE",
            "testKit": "RAPID_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": true,
            "shouldOfferFollowUpTest": true
        }
        """#))

        XCTAssertThrowsError(try endpoint.parse(response))
    }

    func testDecodingVoidRapidSelfReportedTestResult() throws {

        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00Z",
            "testResult": "VOID",
            "testKit": "RAPID_SELF_REPORTED",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        XCTAssertThrowsError(try endpoint.parse(response))
    }

    func testDecodingUnconfirmedWithKeySubmissionSupported() throws {

        let date = "2020-04-23T00:00:00Z"

        let response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "\#(date)",
            "testResult": "POSITIVE",
            "testKit": "RAPID_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": true,
            "shouldOfferFollowUpTest": true
        }
        """#))

        let formatter = ISO8601DateFormatter()

        let expectedResponse = VirologyTestResponse.receivedResult(
            .init(
                virologyTestResult:
                VirologyTestResult(
                    testResult: .positive,
                    testKitType: .rapidResult,
                    endDate:
                    try XCTUnwrap(formatter.date(from: date))
                ),
                diagnosisKeySubmissionSupport: true,
                requiresConfirmatoryTest: true,
                shouldOfferFollowUpTest: true
            ))

        TS.assert(try endpoint.parse(response), equals: expectedResponse)
    }
}
