//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public class SelfDiagnosisManager {
    
    private let httpClient: HTTPClient
    private let calculateIsolationState: (GregorianDay?) -> IsolationState
    
    public var threshold: Double?
    
    init(httpClient: HTTPClient, calculateIsolationState: @escaping (GregorianDay?) -> IsolationState) {
        self.httpClient = httpClient
        self.calculateIsolationState = calculateIsolationState
    }
    
    public func fetchQuestionnaire() -> AnyPublisher<SymptomsQuestionnaire, NetworkRequestError> {
        httpClient.fetch(SymptomsQuestionnaireEndpoint())
    }
    
    public func evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> IsolationState {
        let result = _evaluateSymptoms(symptoms: symptoms, onsetDay: onsetDay, threshold: threshold)
        switch result {
        case .noNeedToIsolate:
            Metrics.signpost(.completedQuestionnaireButDidNotStartIsolation)
        default:
            Metrics.signpost(.completedQuestionnaireAndStartedIsolation)
        }
        return result
    }
    
    public func _evaluateSymptoms(symptoms: [(Symptom, Bool)], onsetDay: GregorianDay?, threshold: Double) -> IsolationState {
        let sum = symptoms.lazy
            .filter { _, isConfirmed in isConfirmed }
            .map { symptom, _ in symptom.riskWeight }
            .reduce(0, +)
        
        guard sum >= threshold else {
            return .noNeedToIsolate
        }
        
        return calculateIsolationState(onsetDay)
    }
}
