//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SelfDiagnosisManaging {
    func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError>
    func evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?)
}

public class SelfDiagnosisManager: SelfDiagnosisManaging {
    private let httpClient: HTTPClient
    private let calculateIsolationState: (GregorianDay?) -> (IsolationState, Bool?)
    
    init(httpClient: HTTPClient, calculateIsolationState: @escaping (GregorianDay?) -> (IsolationState, Bool?)) {
        self.httpClient = httpClient
        self.calculateIsolationState = calculateIsolationState
    }
    
    public func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
        httpClient.fetch(SymptomsQuestionnaireEndpoint())
    }
    
    public func evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?) {
        let result = _evaluateSymptoms(symptoms: symptoms, onsetDay: onsetDay, threshold: threshold)
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
    
    public func _evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> (IsolationState, Bool?) {
        let sum = symptoms.lazy
            .filter { _, isConfirmed in isConfirmed }
            .map { symptom, _ in symptom.riskWeight }
            .reduce(0, +)
        
        guard sum >= threshold else {
            return (.noNeedToIsolate(), nil)
        }
        
        return calculateIsolationState(onsetDay)
    }
}
