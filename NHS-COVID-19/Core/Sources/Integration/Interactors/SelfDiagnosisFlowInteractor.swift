//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

struct SelfDiagnosisFlowInteractor: SelfDiagnosisFlowViewController.Interacting {
    let selfDiagnosisManager: SelfDiagnosisManager
    let orderTest: () -> Void
    let symptomMapper = SymptomMapping()
    let openURL: (URL) -> Void
    
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error> {
        selfDiagnosisManager.fetchQuestionnaire()
            .map { questionnaire in
                self.selfDiagnosisManager.threshold = questionnaire.riskThreshold
                let symptomInfos: [SymptomInfo] = questionnaire.symptoms.map { symptom in
                    self.symptomMapper.interfaceSymptomFrom(domainSymptom: symptom)
                }
                return InterfaceSymptomsQuestionnaire(
                    symptoms: symptomInfos,
                    dateSelectionWindow: questionnaire.dateSelectionWindow
                )
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func evaluateSymptoms(symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Date? {
        switch _evaluateSymptoms(symptoms, onsetDay: onsetDay) {
        case .isolate(let isolation):
            return isolation.endDate
        case .noNeedToIsolate:
            return nil
        }
    }
    
    private func _evaluateSymptoms(_ symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Domain.IsolationState {
        guard let threshold = selfDiagnosisManager.threshold else {
            preconditionFailure("threshold value should have been stored before, but was nil")
        }
        
        let domainSymptoms = symptoms.map { interfaceSymptom in
            (symptomMapper.domainSymptomFrom(interfaceSymptom: interfaceSymptom), interfaceSymptom.isConfirmed)
        }
        
        return selfDiagnosisManager.evaluateSymptoms(symptoms: domainSymptoms, onsetDay: onsetDay, threshold: threshold)
    }
    
    func openTestkitOrder() {
        orderTest()
    }
    
    func furtherAdviceLinkTapped() {
        openURL(ExternalLink.isolationAdvice.url)
    }
    
    func nhs111LinkTapped() {
        openURL(ExternalLink.nhs111Online.url)
    }
}

extension SelfDiagnosisFlowInteractor: BookATestInfoViewControllerInteracting {
    
    public func didTapBookATest() {
        openTestkitOrder()
    }
    
    public func didTapTestingPrivacyNotice() {
        openURL(ExternalLink.testingPrivacyNotice.url)
    }
    
    public func didTapAppPrivacyNotice() {
        openURL(ExternalLink.privacy.url)
    }
    
    public func didTapBookATestForSomeoneElse() {
        openURL(ExternalLink.bookATestForSomeoneElse.url)
    }
}
