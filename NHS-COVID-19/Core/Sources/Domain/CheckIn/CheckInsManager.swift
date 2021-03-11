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
    var mostRecentRiskyVenueCheckInDay: DomainProperty<GregorianDay?>? = nil

    let riskyVenueConfiguration: CachedResponse<RiskyVenueConfiguration>
    
    #warning("refactor this, possibly move bg tasks somewhere else")
    mutating func setMostRecentRiskyVenueCheckInDay(_ property: DomainProperty<GregorianDay?>) {
        mostRecentRiskyVenueCheckInDay = property
    }
    
    func deleteExpiredCheckIns() -> AnyPublisher<Void, Never> {
        let now = LocalDay.today.advanced(by: -Self.numberOfPersistingDays)
        checkInsStoreDeleteExpired(UTCHour(roundedDownToQuarter: now.startOfDay))
        return Just(()).eraseToAnyPublisher()
    }
    
    func evaluateVenuesRisk() -> AnyPublisher<Void, Never> {
        guard let checkIns = checkInsStoreLoad() else {
            return Just(()).eraseToAnyPublisher()
        }
        return fetchRiskyVenues()
            .map(updateRisk)
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
    
    func makeBackgroundJobs(metricsFrequency: Double, housekeepingFrequency: Double) -> [BackgroundTaskAggregator.Job] {
        [
            BackgroundTaskAggregator.Job(
                preferredFrequency: metricsFrequency,
                work: {
                    if self.mostRecentRiskyVenueCheckInDay?.currentValue != nil {
                        Metrics.signpost(.hasReceivedRiskyVenueM2WarningBackgroundTick)
                    }
                    return Empty().eraseToAnyPublisher()
                }
            ),
            BackgroundTaskAggregator.Job(
                preferredFrequency: housekeepingFrequency,
                work: riskyVenueConfiguration.update
            ),
        ]
    }
}

extension CheckInsManager {
    init(checkInsStore: CheckInsStore, httpClient: HTTPClient, riskyVenueConfiguration: CachedResponse<RiskyVenueConfiguration>) {
        self.init(
            checkInsStoreLoad: checkInsStore.load,
            checkInsStoreDeleteExpired: checkInsStore.deleteExpired,
            updateRisk: checkInsStore.updateRisk,
            fetchRiskyVenues: { httpClient.fetch(RiskyVenuesEndpoint()) },
            riskyVenueConfiguration: riskyVenueConfiguration
        )
    }
}
