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
}

class SelfDiagnosisManager: SelfDiagnosisManaging {
    private let httpClient: HTTPClient
    private let calculateIsolationState: (GregorianDay?) -> (IsolationState, Bool?)
    
    init(httpClient: HTTPClient, calculateIsolationState: @escaping (GregorianDay?) -> (IsolationState, Bool?)) {
        self.httpClient = httpClient
        self.calculateIsolationState = calculateIsolationState
    }
    
    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
        httpClient.fetch(SymptomsQuestionnaireEndpoint())
    }
    
    func evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> SelfDiagnosisEvaluation {
        #warning("Simplify this")
        // Should be changed alongside `IsolationContext.handleSymptomsIsolationState`.
        let state = evaluateSymptoms(selectedSymptoms: selectedSymptoms, onsetDay: onsetDay, threshold: threshold)
        switch state.0 {
        case .noNeedToIsolate:
            return .noSymptoms
        case .isolate(let isolation):
            if let shouldChangeAdviceDueToSymptoms = state.1 {
                return .hasSymptoms(isolation, .hasTest(shouldChangeAdviceDueToSymptoms: shouldChangeAdviceDueToSymptoms))
            } else {
                return .hasSymptoms(isolation, .hasNoTest)
            }
        }
    }
    
    private func evaluateSymptoms(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?) {
        let result = _evaluate(selectedSymptoms: selectedSymptoms, onsetDay: onsetDay, threshold: threshold)
        switch result.0 {
        case .noNeedToIsolate:
            Metrics.signpost(.completedQuestionnaireButDidNotStartIsolation)
        default:
            if result.1 == nil {
                Metrics.signpost(.completedQuestionnaireAndStartedIsolation)
            }
        }
        return result
    }
    
    private func _evaluate(selectedSymptoms: [Symptom], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?) {
        let sum = selectedSymptoms
            .map { $0.riskWeight }
            .reduce(0, +)
        
        guard sum >= threshold else {
            return (.noNeedToIsolate(), nil)
        }
        
        return calculateIsolationState(onsetDay)
    }
}
