//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation

struct DiagnosisKeySubmissionEndPoint: HTTPEndpoint {

    var token: DiagnosisKeySubmissionToken
    var isPrivateJourney: Bool
    var testKit: TestKitType

    func request(for input: [TemporaryExposureKey]) throws -> HTTPRequest {
        let payload = Payload(
            token: token,
            diagnosisKeys: input,
            isPrivateJourney: isPrivateJourney,
            testKit: testKit == .labResult ? .labResult : .rapidSelfReported
        )
        let encoding = JSONEncoder()
        let body = try encoding.encode(payload)
        return .post("/submission/diagnosis-keys", body: .json(body))
    }

    func parse(_ response: HTTPResponse) throws {}
}

private struct Payload: Codable {
    struct ExposureKey: Codable {
        var key: Data
        var rollingStartNumber: UInt32
        var rollingPeriod: UInt32
        var transmissionRiskLevel: UInt8
        var daysSinceOnsetOfSymptoms: Int
    }

    enum TestKitType: String, Codable {
        case labResult = "LAB_RESULT"
        case rapidSelfReported = "RAPID_SELF_REPORTED"
    }

    var diagnosisKeySubmissionToken: String
    var temporaryExposureKeys: [ExposureKey]
    var isPrivateJourney: Bool
    var testKit: TestKitType
}

extension Payload {

    fileprivate init(token: DiagnosisKeySubmissionToken, diagnosisKeys: [TemporaryExposureKey], isPrivateJourney: Bool, testKit: TestKitType) {
        let keys = diagnosisKeys.map {
            Payload.ExposureKey(
                key: $0.keyData,
                rollingStartNumber: $0.rollingStartNumber,
                rollingPeriod: $0.rollingPeriod,
                transmissionRiskLevel: $0.transmissionRiskLevel,
                daysSinceOnsetOfSymptoms: $0.daysSinceOnsetOfSymptoms
            )
        }
        self.init(
            diagnosisKeySubmissionToken: token.value,
            temporaryExposureKeys: keys,
            isPrivateJourney: isPrivateJourney,
            testKit: testKit
        )
    }
}
