//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification

class ExposureDetectionClient: ExposureDetectingClient {
    
    private let distributionClient: HTTPClient
    private let submissionClient: HTTPClient
    
    init(distributionClient: HTTPClient, submissionClient: HTTPClient) {
        self.distributionClient = distributionClient
        self.submissionClient = submissionClient
    }
    
    func post(token: DiagnosisKeySubmissionToken, diagnosisKeys: [ENTemporaryExposureKey]) -> AnyPublisher<Void, NetworkRequestError> {
        submissionClient.fetch(DiagnosisKeySubmissionEndPoint(token: token), with: diagnosisKeys)
    }
    
    func getExposureKeys(for increment: Increment) -> AnyPublisher<ZIPManager, NetworkRequestError> {
        switch increment {
        case .twoHourly:
            return distributionClient.fetch(DiagnosisKeyTwoHourlyEndpoint(), with: increment)
        case .daily:
            return distributionClient.fetch(DiagnosisKeyDailyEndpoint(), with: increment)
        }
    }
    
    func getConfiguration() -> AnyPublisher<ExposureDetectionConfiguration, NetworkRequestError> {
        distributionClient.fetch(ExposureNotificationConfigurationEndPoint())
    }
}
