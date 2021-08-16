//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public enum SelfDiagnosisEvaluation: Equatable {
    public enum ExistingPositiveTestState: Equatable {
        case hasNoTest
        case hasTest(shouldChangeAdviceDueToSymptoms: Bool)
    }
    
    case noSymptoms
    case hasSymptoms(Isolation, ExistingPositiveTestState)
}

public protocol SelfDiagnosisManaging {
    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError>
    
    func evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> SelfDiagnosisEvaluation
    
    func shouldShowNewNoSymptomsScreen() -> Bool
}

class SelfDiagnosisManager: SelfDiagnosisManaging {
    private let httpClient: HTTPClient
    private let calculateIsolationState: (GregorianDay?) -> (IsolationState, SelfDiagnosisEvaluation.ExistingPositiveTestState)
    private let _shouldShowNewNoSymptomsScreen: () -> Bool
    
    init(httpClient: HTTPClient,
         calculateIsolationState: @escaping (GregorianDay?) -> (IsolationState, SelfDiagnosisEvaluation.ExistingPositiveTestState),
         shouldShowNewNoSymptomsScreen: @escaping () -> Bool) {
        self.httpClient = httpClient
        self.calculateIsolationState = calculateIsolationState
        _shouldShowNewNoSymptomsScreen = shouldShowNewNoSymptomsScreen
    }
    
    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
        httpClient.fetch(SymptomsQuestionnaireEndpoint())
    }
    
    func evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> SelfDiagnosisEvaluation {
        let evaluation = _evaluate(selectedSymptoms: selectedSymptoms, onsetDay: onsetDay, threshold: threshold)
        Metrics.signpost(evaluation)
        return evaluation
    }
    
    private func _evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> SelfDiagnosisEvaluation {
        let sum = selectedSymptoms
            .map { $0.riskWeight }
            .reduce(0, +)
        
        guard sum >= threshold else {
            return .noSymptoms
        }
        
        let state = calculateIsolationState(onsetDay)
        switch state.0 {
        case .noNeedToIsolate:
            assertionFailure("This should not happen.")
            // We know based on our configuration that if we deem that someone has a symptoms, the provided symptom
            // onset can not be "too long" in the past and therefore we should always be in `isolate` state.
            // However, since this is a dynamic configuration we can‘t write this in a more type-safe way right now.
            return .noSymptoms
        case .isolate(let isolation):
            return .hasSymptoms(isolation, state.1)
        }
    }
    
    func shouldShowNewNoSymptomsScreen() -> Bool {
        _shouldShowNewNoSymptomsScreen()
    }
}
