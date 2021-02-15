//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct LinkVirologyTestResultEndpoint: HTTPEndpoint {
    func request(for input: CTAToken) throws -> HTTPRequest {
        let countryString: String = {
            switch input.country {
            case .england: return "England"
            case .wales: return "Wales"
            }
        }()
        
        let encoder = JSONEncoder()
        let json = try encoder.encode(RequestBody(ctaToken: input.value, country: countryString))
        return .post("/virology-test/v2/cta-exchange", body: .json(json))
    }
    
    func parse(_ response: HTTPResponse) throws -> LinkVirologyTestResultResponse {
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
            Metrics.signpostReceivedFromManual(
                testResult: VirologyTestResult.TestResult(payload.testResult),
                testKitType: VirologyTestResult.TestKitType(payload.testKit),
                requiresConfirmatoryTest: payload.requiresConfirmatoryTest ?? false
            )
            throw VirologyTestResultResponseError.lfdVoidOrNegative
        }
        
        return LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: VirologyTestResult.TestResult(payload.testResult),
                testKitType: VirologyTestResult.TestKitType(payload.testKit),
                endDate: payload.testEndDate
            ),
            diagnosisKeySubmissionSupport: try DiagnosisKeySubmissionSupport(payload),
            requiresConfirmatoryTest: payload.requiresConfirmatoryTest ?? false
        )
    }
}

struct CTAToken: Equatable {
    var value: String
    var country: Country
}

private struct RequestBody: Codable {
    var ctaToken: String
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
    var diagnosisKeySubmissionToken: String?
    var diagnosisKeySubmissionSupported: Bool
    #warning("Remove the optional here as soon as this field is implemented in other envs.")
    var requiresConfirmatoryTest: Bool?
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

enum VirologyTestResultResponseError: Error {
    case noToken
    case lfdVoidOrNegative
    case unconfirmedKeySharingNotSupported
    case unconfirmedNonPostiveNotSupported
}

extension DiagnosisKeySubmissionSupport {
    fileprivate init(_ response: ResponseBody) throws {
        if response.diagnosisKeySubmissionSupported {
            if let token = response.diagnosisKeySubmissionToken {
                self = .supported(diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: token))
            } else {
                throw VirologyTestResultResponseError.noToken
            }
        } else {
            self = .notSupported
        }
    }
}
