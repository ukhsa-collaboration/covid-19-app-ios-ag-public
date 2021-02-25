//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import Localization

struct SelfDiagnosisFlowInteractor: SelfDiagnosisFlowViewController.Interacting {
    let selfDiagnosisManager: SelfDiagnosisManaging
    let orderTest: () -> Void
    let symptomMapper = SymptomMapping()
    let openURL: (URL) -> Void
    
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error> {
        selfDiagnosisManager.fetchQuestionnaire()
            .map { questionnaire in
                let symptomInfos: [SymptomInfo] = questionnaire.symptoms.map { symptom in
                    self.symptomMapper.interfaceSymptomFrom(domainSymptom: symptom)
                }
                return InterfaceSymptomsQuestionnaire(
                    riskThreshold: questionnaire.riskThreshold,
                    symptoms: symptomInfos,
                    dateSelectionWindow: questionnaire.dateSelectionWindow
                )
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func evaluateSymptoms(riskThreshold: Double, symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Date? {
        switch _evaluateSymptoms(riskThreshold: riskThreshold, symptoms: symptoms, onsetDay: onsetDay) {
        case .isolate(let isolation):
            return isolation.endDate
        case .noNeedToIsolate:
            return nil
        }
    }
    
    private func _evaluateSymptoms(riskThreshold: Double, symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Domain.IsolationState {
        let domainSymptoms = symptoms.map { interfaceSymptom in
            (symptomMapper.domainSymptomFrom(interfaceSymptom: interfaceSymptom), interfaceSymptom.isConfirmed)
        }
        
        return selfDiagnosisManager.evaluateSymptoms(symptoms: domainSymptoms, onsetDay: onsetDay, threshold: riskThreshold)
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
    
    func exposureFAQsLinkTapped() {
        openURL(ExternalLink.exposureFAQs.url)
        
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
