//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import UserNotifications

struct ExposureKeysManager {
    var controller: ExposureNotificationDetectionController
    var submissionClient: HTTPClient
    
    func sendKeys(for onsetDay: GregorianDay, token: DiagnosisKeySubmissionToken) -> AnyPublisher<Void, Error> {
        controller.getDiagnosisKeys()
            .map { keys in
                keys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
                    .filter { $0.transmissionRiskLevel > 0 }
            }
            .flatMap {
                self.post(token: token, diagnosisKeys: $0).mapError { $0 as Error }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func post(token: DiagnosisKeySubmissionToken, diagnosisKeys: [TemporaryExposureKey]) -> AnyPublisher<Void, NetworkRequestError> {
        submissionClient.fetch(DiagnosisKeySubmissionEndPoint(token: token), with: diagnosisKeys)
    }
    
}
