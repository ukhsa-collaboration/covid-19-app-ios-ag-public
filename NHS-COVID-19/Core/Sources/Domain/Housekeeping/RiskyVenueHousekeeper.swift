//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class RiskyVenueHousekeeper {
    private let getHousekeepingDeletionPeriod: () -> DayDuration?
    private let getMostRecentCheckInDay: () -> GregorianDay?
    private let getToday: () -> GregorianDay
    private let clearData: () -> Void
    
    init(getHousekeepingDeletionPeriod: @escaping () -> DayDuration?,
         getMostRecentCheckInDay: @escaping () -> GregorianDay?,
         getToday: @escaping () -> GregorianDay,
         clearData: @escaping () -> Void) {
        self.getHousekeepingDeletionPeriod = getHousekeepingDeletionPeriod
        self.getMostRecentCheckInDay = getMostRecentCheckInDay
        self.getToday = getToday
        self.clearData = clearData
    }
    
    convenience init(checkInsStore: CheckInsStore,
                     getToday: @escaping () -> GregorianDay) {
        self.init(
            getHousekeepingDeletionPeriod: { checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest },
            getMostRecentCheckInDay: { checkInsStore.mostRecentRiskyCheckInDay },
            getToday: getToday,
            clearData: { checkInsStore.deleteMostRecentRiskyVenueCheckIn() }
        )
    }
    
    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        guard let housekeepingDeletionPeriod = getHousekeepingDeletionPeriod()?.days else {
            return Empty().eraseToAnyPublisher()
        }
        
        guard let mostRecentCheckInDay = getMostRecentCheckInDay() else {
            return Empty().eraseToAnyPublisher()
        }
        
        let daysSinceMostRiskyVenueCheckIn = mostRecentCheckInDay.distance(to: getToday())
        
        if daysSinceMostRiskyVenueCheckIn >= housekeepingDeletionPeriod {
            clearData()
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
