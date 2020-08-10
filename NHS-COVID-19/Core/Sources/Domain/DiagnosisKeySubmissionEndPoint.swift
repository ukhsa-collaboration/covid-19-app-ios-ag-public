//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation

struct DiagnosisKeySubmissionEndPoint: HTTPEndpoint {
    
    var token: DiagnosisKeySubmissionToken
    
    func request(for input: [ENTemporaryExposureKey]) throws -> HTTPRequest {
        let payload = Payload(token: token, diagnosisKeys: input)
        let encoding = JSONEncoder()
        let body = try encoding.encode(payload)
        return .post("/submission/diagnosis-keys", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
}

private struct Payload: Codable {
    struct TemporaryExposureKey: Codable {
        var key: Data
        var rollingStartNumber: UInt32
        var rollingPeriod: UInt32
    }
    
    var diagnosisKeySubmissionToken: String
    var temporaryExposureKeys: [TemporaryExposureKey]
}

extension Payload {
    
    fileprivate init(token: DiagnosisKeySubmissionToken, diagnosisKeys: [ENTemporaryExposureKey]) {
        let keys = diagnosisKeys.map {
            Payload.TemporaryExposureKey(
                key: $0.keyData,
                rollingStartNumber: $0.rollingStartNumber,
                rollingPeriod: $0.rollingPeriod
            )
        }
        self.init(
            diagnosisKeySubmissionToken: token.value,
            temporaryExposureKeys: keys
        )
    }
}
