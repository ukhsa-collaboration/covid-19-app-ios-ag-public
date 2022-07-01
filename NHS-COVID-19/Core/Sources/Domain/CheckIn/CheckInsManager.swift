//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public struct CheckInsManager {

    private static let numberOfPersistingDays: Int = 21

    var checkInsStoreLoad: () -> CheckIns?
    var checkInsStoreDeleteExpired: (UTCHour) -> Void
    var updateRisk: ([RiskyVenue]) -> Void
    var fetchRiskyVenues: () -> AnyPublisher<[RiskyVenue], NetworkRequestError>

    func deleteExpiredCheckIns() -> AnyPublisher<Void, Never> {
        let now = LocalDay.today.advanced(by: -Self.numberOfPersistingDays)
        checkInsStoreDeleteExpired(UTCHour(roundedDownToQuarter: now.startOfDay))
        return Just(()).eraseToAnyPublisher()
    }

    func evaluateVenuesRisk() -> AnyPublisher<Void, Never> {
        guard checkInsStoreLoad() != nil else {
            return Just(()).eraseToAnyPublisher()
        }
        return fetchRiskyVenues()
            .map(updateRisk)
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}

extension CheckInsManager {
    init(checkInsStore: CheckInsStore, httpClient: HTTPClient) {
        self.init(
            checkInsStoreLoad: checkInsStore.load,
            checkInsStoreDeleteExpired: checkInsStore.deleteExpired,
            updateRisk: checkInsStore.updateRisk,
            fetchRiskyVenues: { httpClient.fetch(RiskyVenuesEndpoint()) }
        )
    }
}
