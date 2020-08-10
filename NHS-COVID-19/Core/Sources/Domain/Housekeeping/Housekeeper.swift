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
    private let hasPendingTestTokens: () -> Bool
    private let clearData: () -> Void
    
    init(getHousekeepingDeletionPeriod: @escaping () -> DayDuration,
         getToday: @escaping () -> GregorianDay,
         getIsolationLogicalState: @escaping () -> IsolationLogicalState,
         hasPendingTestTokens: @escaping () -> Bool,
         clearData: @escaping () -> Void) {
        self.getHousekeepingDeletionPeriod = getHousekeepingDeletionPeriod
        self.getToday = getToday
        self.getIsolationLogicalState = getIsolationLogicalState
        self.hasPendingTestTokens = hasPendingTestTokens
        self.clearData = clearData
    }
    
    convenience init(isolationStateStore: IsolationStateStore,
                     isolationStateManager: IsolationStateManager,
                     virologyTestingStateStore: VirologyTestingStateStore) {
        self.init(
            getHousekeepingDeletionPeriod: { isolationStateStore.configuration.housekeepingDeletionPeriod },
            getToday: { .today },
            getIsolationLogicalState: { isolationStateManager.state },
            hasPendingTestTokens: {
                guard let tokens = virologyTestingStateStore.virologyTestTokens else {
                    return false
                }
                return !tokens.isEmpty
            },
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
        let hasPendingTasks = hasPendingTestTokens() || isolationLogicalState.hasPendingTasks
        
        switch daysSinceEndOfIsolation {
        case 0 ..< housekeepingDeletionPeriod where !hasPendingTasks:
            fallthrough
        case housekeepingDeletionPeriod ... .max:
            clearData()
        default:
            break
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
