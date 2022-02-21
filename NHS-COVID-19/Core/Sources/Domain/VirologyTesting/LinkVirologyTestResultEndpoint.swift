//
// Copyright © 2021 DHSC. All rights reserved.
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
        
        if payload.requiresConfirmatoryTest && payload.testResult != .positive {
            signpostReceivedFromManual(payload)
            throw VirologyTestResultResponseError.unconfirmedNonPostiveNotSupported
        }
        
        if payload.testKit == .rapidResult || payload.testKit == .rapidSelfReported, payload.testResult != .positive {
            signpostReceivedFromManual(payload)
            throw VirologyTestResultResponseError.lfdVoidOrNegative
        }
        
        if !payload.requiresConfirmatoryTest, payload.confirmatoryDayLimit != nil {
            signpostReceivedFromManual(payload)
            throw VirologyTestResultResponseError.confirmatoryTimeLimitProvidedWhenNoConfirmatoryTestRequired
        }
        
        if !payload.requiresConfirmatoryTest, payload.shouldOfferFollowUpTest {
            throw VirologyTestResultResponseError.confirmedTestOfferingFollowUpTest
        }
        
        return LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: VirologyTestResult.TestResult(payload.testResult),
                testKitType: VirologyTestResult.TestKitType(payload.testKit),
                endDate: payload.testEndDate
            ),
            diagnosisKeySubmissionSupport: try DiagnosisKeySubmissionSupport(payload),
            requiresConfirmatoryTest: payload.requiresConfirmatoryTest,
            shouldOfferFollowUpTest: payload.shouldOfferFollowUpTest,
            confirmatoryDayLimit: payload.confirmatoryDayLimit
        )
    }
    
    private func signpostReceivedFromManual(_ payload: ResponseBody) {
        Metrics.signpostReceivedFromManual(
            testResult: VirologyTestResult.TestResult(payload.testResult),
            testKitType: VirologyTestResult.TestKitType(payload.testKit),
            requiresConfirmatoryTest: payload.requiresConfirmatoryTest
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
    var diagnosisKeySubmissionToken: String?
    var diagnosisKeySubmissionSupported: Bool
    var requiresConfirmatoryTest: Bool
    var shouldOfferFollowUpTest: Bool
    var confirmatoryDayLimit: Int?
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
        case .plod:
            self = .plod
        }
    }
}

enum VirologyTestResultResponseError: Error {
    case noToken
    case lfdVoidOrNegative
    case confirmatoryTimeLimitProvidedWhenNoConfirmatoryTestRequired
    case unconfirmedNonPostiveNotSupported
    case confirmedTestOfferingFollowUpTest
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
