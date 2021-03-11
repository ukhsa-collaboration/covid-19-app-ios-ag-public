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
    
    init(checkInsStore: CheckInsStore, checkInsManager: CheckInsManager, qrCodeScanner: QRCodeScanner, currentDateProvider: DateProviding) {
        self.checkInsStore = checkInsStore
        self.checkInsManager = checkInsManager
        self.qrCodeScanner = qrCodeScanner
        self.currentDateProvider = currentDateProvider
        self.checkInsManager.setMostRecentRiskyVenueCheckInDay(didRecentlyVisitSevereRiskyVenueProperty()) 
    }
    
    public func didRecentlyVisitSevereRiskyVenue() -> AnyPublisher<GregorianDay?, Never> {
        checkInsStore.$mostRecentRiskyCheckInDay.combineLatest(currentDateProvider.today) { mostRecentRiskyCheckInDay, today -> GregorianDay? in
            guard let mostRecentRiskyCheckInDay = mostRecentRiskyCheckInDay,
                let mostRecentRiskyVenueConfiguration = checkInsStore.mostRecentRiskyVenueConfiguration
            else {
                return nil
            }
            return mostRecentRiskyCheckInDay.distance(to: currentDateProvider.currentGregorianDay(timeZone: .current)) < mostRecentRiskyVenueConfiguration.optionToBookATest.days ? mostRecentRiskyCheckInDay : nil
        }
        .eraseToAnyPublisher()
    }
    
    public func didRecentlyVisitSevereRiskyVenueProperty() -> DomainProperty<GregorianDay?> {
        didRecentlyVisitSevereRiskyVenue().domainProperty()
    }
}
