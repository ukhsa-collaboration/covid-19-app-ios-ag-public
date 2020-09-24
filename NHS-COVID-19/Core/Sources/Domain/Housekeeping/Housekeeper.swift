//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class Housekeeper {
    private let getHousekeepingDeletionPeriod: () -> DayDuration
    private let getToday: () -> GregorianDay
    private let getIsolationLogicalState: () -> IsolationLogicalState
    private let clearData: () -> Void
    
    init(getHousekeepingDeletionPeriod: @escaping () -> DayDuration,
         getToday: @escaping () -> GregorianDay,
         getIsolationLogicalState: @escaping () -> IsolationLogicalState,
         clearData: @escaping () -> Void) {
        self.getHousekeepingDeletionPeriod = getHousekeepingDeletionPeriod
        self.getToday = getToday
        self.getIsolationLogicalState = getIsolationLogicalState
        self.clearData = clearData
    }
    
    convenience init(isolationStateStore: IsolationStateStore,
                     isolationStateManager: IsolationStateManager,
                     virologyTestingStateStore: VirologyTestingStateStore) {
        self.init(
            getHousekeepingDeletionPeriod: { isolationStateStore.configuration.housekeepingDeletionPeriod },
            getToday: { .today },
            getIsolationLogicalState: { isolationStateManager.state },
            clearData: {
                virologyTestingStateStore.delete()
                isolationStateStore.isolationStateInfo = nil
            }
        )
    }
    
    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        let isolationLogicalState = getIsolationLogicalState()
        guard let isolationEndDate = isolationLogicalState.isolation?.untilStartOfDay.gregorianDay else {
            return Empty().eraseToAnyPublisher()
        }
        
        let housekeepingDeletionPeriod = getHousekeepingDeletionPeriod().days
        let daysSinceEndOfIsolation = isolationEndDate.distance(to: getToday())
        
        if daysSinceEndOfIsolation >= housekeepingDeletionPeriod {
            clearData()
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
