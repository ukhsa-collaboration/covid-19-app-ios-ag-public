//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common

public struct CheckInContext {
    public var checkInsStore: CheckInsStore
    public var checkInsManager: CheckInsManager
    public var qrCodeScanner: QRCodeScanner
    public var currentDateProvider: DateProviding
    private let riskyVenueConfiguration: CachedResponse<RiskyVenueConfiguration>
    public var recentlyVisitedSevereRiskyVenue: DomainProperty<GregorianDay?>
    
    init(
        checkInsStore: CheckInsStore,
        checkInsManager: CheckInsManager,
        qrCodeScanner: QRCodeScanner,
        currentDateProvider: DateProviding,
        riskyVenueConfiguration: CachedResponse<RiskyVenueConfiguration>
    ) {
        self.checkInsStore = checkInsStore
        self.checkInsManager = checkInsManager
        self.qrCodeScanner = qrCodeScanner
        self.currentDateProvider = currentDateProvider
        self.riskyVenueConfiguration = riskyVenueConfiguration
        
        recentlyVisitedSevereRiskyVenue = checkInsStore.$mostRecentRiskyCheckInDay.combineLatest(currentDateProvider.today, checkInsStore.$mostRecentRiskyVenueConfiguration) { mostRecentRiskyCheckInDay, today, mostRecentRiskyVenueConfiguration -> GregorianDay? in
            guard let mostRecentRiskyCheckInDay = mostRecentRiskyCheckInDay,
                let mostRecentRiskyVenueConfiguration = mostRecentRiskyVenueConfiguration
            else {
                return nil
            }
            return mostRecentRiskyCheckInDay.distance(to: currentDateProvider.currentGregorianDay(timeZone: .current)) < mostRecentRiskyVenueConfiguration.optionToBookATest.days ? mostRecentRiskyCheckInDay : nil
        }
        .domainProperty()
    }
    
    func makeBackgroundJobs() -> [BackgroundTaskAggregator.Job] {
        [
            BackgroundTaskAggregator.Job(
                work: recordMetrics
            ),
            BackgroundTaskAggregator.Job(
                work: riskyVenueConfiguration.update
            ),
        ]
    }
    
    private func recordMetrics() -> AnyPublisher<Void, Never> {
        if recentlyVisitedSevereRiskyVenue.currentValue != nil {
            Metrics.signpost(.hasReceivedRiskyVenueM2WarningBackgroundTick)
        }
        return Empty().eraseToAnyPublisher()
    }
}
