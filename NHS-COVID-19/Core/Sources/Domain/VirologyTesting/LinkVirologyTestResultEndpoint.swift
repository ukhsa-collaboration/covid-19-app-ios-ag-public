//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct LinkVirologyTestResultEndpoint: HTTPEndpoint {
    func request(for input: CTAToken) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let json = try encoder.encode(RequestBody(ctaToken: input.value))
        
        return .post("/virology-test/cta-exchange", body: .json(json))
    }
    
    func parse(_ response: HTTPResponse) throws -> LinkVirologyTestResultResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking
        let payload = try decoder.decode(ResponseBody.self, from: response.body.content)
        return LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: VirologyTestResult.TestResult(payload.testResult),
                endDate: payload.testEndDate
            ),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: payload.diagnosisKeySubmissionToken)
        )
    }
}

struct CTAToken: Equatable {
    var value: String
}

private struct RequestBody: Codable {
    var ctaToken: String
}

private struct ResponseBody: Codable {
    enum TestResult: String, Codable {
        case positive = "POSITIVE"
        case negative = "NEGATIVE"
        case void = "VOID"
    }
    
    var testEndDate: Date
    var testResult: TestResult
    var diagnosisKeySubmissionToken: String
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
