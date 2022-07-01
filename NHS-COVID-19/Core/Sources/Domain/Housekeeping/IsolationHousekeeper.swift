//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class IsolationHousekeeper {
    private let getHousekeepingDeletionPeriod: () -> DayDuration
    private let getToday: () -> GregorianDay
    private let getIsolationLogicalState: () -> IsolationLogicalState
    private let getIsolationStateInfo: () -> IsolationInfo
    private let clearData: () -> Void

    init(getHousekeepingDeletionPeriod: @escaping () -> DayDuration,
         getToday: @escaping () -> GregorianDay,
         getIsolationLogicalState: @escaping () -> IsolationLogicalState,
         getIsolationStateInfo: @escaping () -> IsolationInfo,
         clearData: @escaping () -> Void) {
        self.getHousekeepingDeletionPeriod = getHousekeepingDeletionPeriod
        self.getToday = getToday
        self.getIsolationLogicalState = getIsolationLogicalState
        self.getIsolationStateInfo = getIsolationStateInfo
        self.clearData = clearData
    }

    convenience init(isolationStateStore: IsolationStateStore,
                     isolationStateManager: IsolationStateManager,
                     virologyTestingStateStore: VirologyTestingStateStore,
                     getToday: @escaping () -> GregorianDay) {
        self.init(
            getHousekeepingDeletionPeriod: { isolationStateStore.configuration.housekeepingDeletionPeriod },
            getToday: getToday,
            getIsolationLogicalState: { isolationStateManager.state },
            getIsolationStateInfo: { isolationStateStore.isolationInfo },
            clearData: {
                virologyTestingStateStore.deleteExpiredData()
                isolationStateStore.isolationStateInfo = nil
            }
        )
    }

    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        let housekeepingDeletionPeriod = getHousekeepingDeletionPeriod().days

        let isolationLogicalState = getIsolationLogicalState()

        guard let isolationEndDate = isolationLogicalState.isolation?.untilStartOfDay.gregorianDay else {
            clearTestDataForManualTestWithoutIsolation()
            return Empty().eraseToAnyPublisher()
        }

        let daysSinceEndOfIsolation = isolationEndDate.distance(to: getToday())

        if daysSinceEndOfIsolation >= housekeepingDeletionPeriod {
            clearData()
        }

        return Empty().eraseToAnyPublisher()
    }

    #warning("""
        The housekeeping clears the isolation data and the test data after 14 days of isolation ended. However, currently when we receive a negative or void test, we do not create an isolation logical state so the data is inside isolation info but never gets cleared.

        Alternatively, we should create an isolation object when we receive a negative or void test with a case that never isolated and housekeeping would work as it was before we added this function.
    """)
    func clearTestDataForManualTestWithoutIsolation() {
        let housekeepingDeletionPeriod = getHousekeepingDeletionPeriod().days
        guard let indexCaseInfo = getIsolationStateInfo().indexCaseInfo else {
            return
        }

        guard let testInfo = indexCaseInfo.testInfo, testInfo.result != .positive else {
            return
        }

        switch indexCaseInfo.isolationTrigger {
        case .manualTestEntry(let npexDay):
            if npexDay.distance(to: getToday()) >= housekeepingDeletionPeriod {
                clearData()
            }
        case .selfDiagnosis: break
        }
    }
}
