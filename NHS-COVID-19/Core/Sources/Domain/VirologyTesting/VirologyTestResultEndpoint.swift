//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct VirologyTestResultEndpoint: HTTPEndpoint {
    func request(for input: VirologyTestResultRequest) throws -> HTTPRequest {
        let countryString: String = {
            switch input.country {
            case .england: return "England"
            case .wales: return "Wales"
            }
        }()

        let encoder = JSONEncoder()
        let json = try encoder.encode(RequestBody(testResultPollingToken: input.pollingToken.value, country: countryString))

        return .post("/virology-test/v2/results", body: .json(json))
    }

    func parse(_ response: HTTPResponse) throws -> VirologyTestResponse {
        switch response.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .appNetworking
            let payload = try decoder.decode(ResponseBody.self, from: response.body.content)

            if payload.requiresConfirmatoryTest && payload.testResult != .positive {
                signpostReceivedViaPolling(payload)
                throw VirologyTestResultResponseError.unconfirmedNonPostiveNotSupported
            }

            if payload.testKit == .rapidResult || payload.testKit == .rapidSelfReported, payload.testResult != .positive {
                signpostReceivedViaPolling(payload)
                throw VirologyTestResultResponseError.lfdVoidOrNegative
            }

            if !payload.requiresConfirmatoryTest, payload.shouldOfferFollowUpTest {
                throw VirologyTestResultResponseError.confirmedTestOfferingFollowUpTest
            }

            return .receivedResult(
                PollVirologyTestResultResponse(
                    virologyTestResult: VirologyTestResult(
                        testResult: VirologyTestResult.TestResult(payload.testResult),
                        testKitType: VirologyTestResult.TestKitType(payload.testKit),
                        endDate: payload.testEndDate
                    ),
                    diagnosisKeySubmissionSupport: payload.diagnosisKeySubmissionSupported,
                    requiresConfirmatoryTest: payload.requiresConfirmatoryTest,
                    shouldOfferFollowUpTest: payload.shouldOfferFollowUpTest,
                    confirmatoryDayLimit: payload.confirmatoryDayLimit
                )
            )
        default:
            return .noResultYet
        }
    }

    private func signpostReceivedViaPolling(_ payload: ResponseBody) {
        Metrics.signpostReceivedViaPolling(
            testResult: VirologyTestResult.TestResult(payload.testResult),
            testKitType: VirologyTestResult.TestKitType(payload.testKit),
            requiresConfirmatoryTest: payload.requiresConfirmatoryTest
        )
    }
}

struct VirologyTestResultRequest {
    let pollingToken: PollingToken
    let country: Country
}

private struct RequestBody: Codable {
    var testResultPollingToken: String
    var country: String
}

private struct ResponseBody: Codable {
    enum TestResult: String, Codable {
        case positive = "POSITIVE"
        case negative = "NEGATIVE"
        case void = "VOID"
        case plod = "PLOD"
    }

    enum TestKitType: String, Codable {
        case labResult = "LAB_RESULT"
        case rapidResult = "RAPID_RESULT"
        case rapidSelfReported = "RAPID_SELF_REPORTED"
    }

    var testEndDate: Date
    var testResult: TestResult
    var testKit: TestKitType
    var diagnosisKeySubmissionSupported: Bool
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool
    var confirmatoryDayLimit: Int?
}

private extension VirologyTestResult.TestResult {
    init(_ testResult: ResponseBody.TestResult) {
        switch testResult {
        case .negative:
            self = .negative
        case .positive:
            self = .positive
        case .void:
            self = .void
        case .plod:
            self = .plod
        }
    }
}

private extension VirologyTestResult.TestKitType {
    init(_ testKitType: ResponseBody.TestKitType) {
        switch testKitType {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
}
