//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class SymptomsCheckerHousekeeper {
    private let getHousekeepingDeletionPeriod: () -> DayDuration?
    private let getMostRecentCompletedQuestionnaireDay: () -> GregorianDay?
    private let getToday: () -> GregorianDay
    private let clearData: () -> Void

    init(getHousekeepingDeletionPeriod: @escaping () -> DayDuration?,
         getMostRecentCompletedQuestionnaireDay: @escaping () -> GregorianDay?,
         getToday: @escaping () -> GregorianDay,
         clearData: @escaping () -> Void) {
        self.getHousekeepingDeletionPeriod = getHousekeepingDeletionPeriod
        self.getMostRecentCompletedQuestionnaireDay = getMostRecentCompletedQuestionnaireDay
        self.getToday = getToday
        self.clearData = clearData
    }

    convenience init(symptomsCheckerStore: SymptomsCheckerStore, getToday: @escaping () -> GregorianDay) {
        self.init(
            getHousekeepingDeletionPeriod: { symptomsCheckerStore.configuration.analyticsPeriod },
            getMostRecentCompletedQuestionnaireDay: { symptomsCheckerStore.lastCompletedSymptomsQuestionnaireDay.currentValue },
            getToday: getToday,
            clearData: { symptomsCheckerStore.delete() }
        )
    }

    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        guard let housekeepingDeletionPeriod = getHousekeepingDeletionPeriod()?.days else {
            return Empty().eraseToAnyPublisher()
        }

        guard let mostRecentCompletedQuestionnaireDay = getMostRecentCompletedQuestionnaireDay() else {
            return Empty().eraseToAnyPublisher()
        }

        let daysSinceCompletedQuestionnaire = mostRecentCompletedQuestionnaireDay.distance(to: getToday())

        if daysSinceCompletedQuestionnaire >= housekeepingDeletionPeriod {
            clearData()
        }

        return Empty().eraseToAnyPublisher()
    }
}
