//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct OrderTestKitEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .post("/virology-test/v2/order", body: .plain(""))
    }
    
    func parse(_ response: HTTPResponse) throws -> OrderTestkitResponse {
        let payload = try JSONDecoder().decode(Payload.self, from: response.body.content)
        return OrderTestkitResponse(
            testOrderWebsite: payload.websiteUrlWithQuery,
            referenceCode: ReferenceCode(value: payload.tokenParameterValue),
            testResultPollingToken: PollingToken(value: payload.testResultPollingToken),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: payload.diagnosisKeySubmissionToken)
        )
    }
}

private struct Payload: Codable {
    var websiteUrlWithQuery: URL
    var tokenParameterValue: String
    var testResultPollingToken: String
    var diagnosisKeySubmissionToken: String
}
