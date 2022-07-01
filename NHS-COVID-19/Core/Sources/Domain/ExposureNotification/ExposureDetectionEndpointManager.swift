//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct ExposureDetectionEndpointManager {

    var distributionClient: HTTPClient
    var fileStorage: FileStoring

    func getExposureKeys(for increment: Increment) -> AnyPublisher<ZIPManager, NetworkRequestError> {
        loadResponse(for: increment)
            .map(ZIPManager.init)
            .eraseToAnyPublisher()
    }

    func getConfiguration() -> AnyPublisher<ExposureDetectionConfiguration, NetworkRequestError> {
        distributionClient.fetch(ExposureNotificationConfigurationEndPoint())
    }

    private func loadResponse(for increment: Increment) -> AnyPublisher<Data, NetworkRequestError> {
        let cachedData = fileStorage.read(increment.identifier)
        if let cachedData = cachedData {
            return Result.success(cachedData).publisher.eraseToAnyPublisher()
        } else {
            let fetchRequest: AnyPublisher<Data, NetworkRequestError>
            switch increment {
            case .twoHourly:
                fetchRequest = distributionClient.fetch(DiagnosisKeyTwoHourlyEndpoint(), with: increment)
            case .daily:
                fetchRequest = distributionClient.fetch(DiagnosisKeyDailyEndpoint(), with: increment)
            }

            return fetchRequest
                .handleEvents(receiveOutput: { response in
                    self.save(response: response, for: increment)
                })
                .eraseToAnyPublisher()
        }
    }

    private func save(response: Data, for increment: Increment) {
        fileStorage.save(response, to: increment.identifier)
    }

}
