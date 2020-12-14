//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Logging

struct IsolationPaymentTokenUpdateEndpoint: HTTPEndpoint {
    
    func request(for input: IsolationPaymentTokenUpdate) throws -> HTTPRequest {
        let payload = RequestBodyPayload(input)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return .post("/isolation-payment/ipc-token/update", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws -> URL {
        let decoder = JSONDecoder()
        let payload = try decoder.decode(ResponseBodyPayload.self, from: response.body.content)
        return payload.websiteUrlWithQuery
    }
}

private struct RequestBodyPayload: Encodable {
    var ipcToken: String
    var riskyEncounterDate: Date
    var isolationPeriodEndDate: Date
    
    init(_ updatePayload: IsolationPaymentTokenUpdate) {
        ipcToken = updatePayload.ipcToken
        riskyEncounterDate = updatePayload.riskyEncounterDay.startDate(in: .utc)
        isolationPeriodEndDate = updatePayload.isolationPeriodEndsAtStartOfDay.startDate(in: .utc)
    }
}

private struct ResponseBodyPayload: Decodable {
    var websiteUrlWithQuery: URL
}
