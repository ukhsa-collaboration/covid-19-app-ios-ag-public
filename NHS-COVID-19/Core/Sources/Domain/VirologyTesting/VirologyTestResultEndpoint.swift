//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct VirologyTestResultEndpoint: HTTPEndpoint {
    func request(for input: PollingToken) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let json = try encoder.encode(RequestBody(testResultPollingToken: input.value))
        
        return .post("/virology-test/results", body: .json(json))
    }
    
    func parse(_ response: HTTPResponse) throws -> VirologyTestResponse {
        switch response.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .appNetworking
            let payload = try decoder.decode(ResponseBody.self, from: response.body.content)
            return .receivedResult(
                VirologyTestResult(
                    testResult: VirologyTestResult.TestResult(payload.testResult),
                    endDate: payload.testEndDate
                )
            )
        default:
            return .noResultYet
        }
    }
}

private struct RequestBody: Codable {
    var testResultPollingToken: String
}

private struct ResponseBody: Codable {
    enum TestResult: String, Codable {
        case positive = "POSITIVE"
        case negative = "NEGATIVE"
        case void = "VOID"
    }
    
    var testEndDate: Date
    var testResult: TestResult
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
