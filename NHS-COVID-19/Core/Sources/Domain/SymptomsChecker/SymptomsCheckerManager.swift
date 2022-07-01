//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SymptomsCheckerManaging {
    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError>
    func store(shouldTryToStayAtHome: Bool)
    func invoke(symptomCheckerQuestions: SymptomCheckerQuestions) -> SymptomCheckerAdviceResult?
}

class SymptomsCheckerManager: SymptomsCheckerManaging {
    public var symptomsCheckerStore: SymptomsCheckerStore
    public var currentDateProvider: DateProviding
    private let httpClient: HTTPClient
    private let symptomCheckerAdviceHandler = SymptomCheckerAdviceHandler()

    init(symptomsCheckerStore: SymptomsCheckerStore, currentDateProvider: DateProviding, httpClient: HTTPClient) {
        self.symptomsCheckerStore = symptomsCheckerStore
        self.currentDateProvider = currentDateProvider
        self.httpClient = httpClient
    }

    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
        httpClient.fetch(SymptomsQuestionnaireEndpoint())
    }

    func invoke(symptomCheckerQuestions: SymptomCheckerQuestions) -> SymptomCheckerAdviceResult? {
        symptomCheckerAdviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)
    }

    func store(shouldTryToStayAtHome: Bool) {
        let currentDay = currentDateProvider.currentGregorianDay(timeZone: .current)
        symptomsCheckerStore.save(lastCompletedSymptomsQuestionnaireDay: currentDay, toldToStayHome: shouldTryToStayAtHome)
    }

    func deleteAll() {
        symptomsCheckerStore.delete()
    }

    func makeBackgroundJobs() -> [BackgroundTaskAggregator.Job] {
        [
            BackgroundTaskAggregator.Job(
                work: recordMetrics
            )
        ]
    }

    private func recordMetrics() -> AnyPublisher<Void, Never> {
        guard let lastCompletedSymptomsQuestionnaireDay = symptomsCheckerStore.lastCompletedSymptomsQuestionnaireDay.currentValue else {
            return Empty().eraseToAnyPublisher()
        }

        let daysSinceCompletedQuestionnaire = lastCompletedSymptomsQuestionnaireDay.distance(to: currentDateProvider.currentGregorianDay(timeZone: .current))

        if daysSinceCompletedQuestionnaire < symptomsCheckerStore.configuration.analyticsPeriod.days {
            Metrics.signpost(.hasCompletedV2SymptomsQuestionnaireBackgroundTick)
            if symptomsCheckerStore.toldToStayHome.currentValue == true {
                Metrics.signpost(.hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick)
            }
        }

        return Empty().eraseToAnyPublisher()
    }
}
