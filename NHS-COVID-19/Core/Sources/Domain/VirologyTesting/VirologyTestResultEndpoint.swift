//
// Copyright © 2020 NHSX. All rights reserved.
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
            
            if (payload.requiresConfirmatoryTest ?? false) && payload.diagnosisKeySubmissionSupported {
                throw VirologyTestResultResponseError.unconfirmedKeySharingNotSupported
            }
            
            if (payload.requiresConfirmatoryTest ?? false) && payload.testResult != .positive {
                throw VirologyTestResultResponseError.unconfirmedNonPostiveNotSupported
            }
            
            if payload.testKit == .rapidResult || payload.testKit == .rapidSelfReported, payload.testResult != .positive {
                throw VirologyTestResultResponseError.lfdVoidOrNegative
            }
            
            return .receivedResult(
                PollVirologyTestResultResponse(
                    virologyTestResult: VirologyTestResult(
                        testResult: VirologyTestResult.TestResult(payload.testResult),
                        testKitType: VirologyTestResult.TestKitType(payload.testKit),
                        endDate: payload.testEndDate
                    ),
                    diagnosisKeySubmissionSupport: payload.diagnosisKeySubmissionSupported,
                    requiresConfirmatoryTest: payload.requiresConfirmatoryTest ?? false
                )
            )
        default:
            return .noResultYet
        }
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
    #warning("Remove the optional here as soon as this field is implemented in other envs.")
    var requiresConfirmatoryTest: Bool?
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
