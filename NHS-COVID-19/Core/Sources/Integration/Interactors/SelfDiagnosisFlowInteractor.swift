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
    let coordinator: ApplicationCoordinator
    let orderTest: () -> Void
    let symptomMapper = SymptomMapping()
    let externalLinkOpener: ExternalLinkOpening
    
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
        if let furtherAdviceLink = URL(string: ExternalLink.isolationAdvice.rawValue) {
            externalLinkOpener.openExternalLink(url: furtherAdviceLink)
        }
    }
    
    func nhs111LinkTapped() {
        if let nhs111Link = URL(string: ExternalLink.nhs111Online.rawValue) {
            externalLinkOpener.openExternalLink(url: nhs111Link)
        }
    }
}

extension SelfDiagnosisFlowInteractor: BookATestInfoViewControllerInteracting {
    
    public func didTapBookATest() {
        openTestkitOrder()
    }
    
    public func didTapTestingPrivacyNotice() {
        guard let testingPrivacyNoticeLink = URL(string: ExternalLink.testingPrivacyNotice.rawValue) else { return }
        
        externalLinkOpener.openExternalLink(url: testingPrivacyNoticeLink)
    }
    
    public func didTapAppPrivacyNotice() {
        guard let appPrivacyNoticeLink = URL(string: ExternalLink.privacy.rawValue) else { return }
        
        externalLinkOpener.openExternalLink(url: appPrivacyNoticeLink)
    }
    
    public func didTapBookATestForSomeoneElse() {
        guard let bookATestForSomeoneElseLink = URL(string: ExternalLink.bookATestForSomeoneElse.rawValue) else { return }
        
        externalLinkOpener.openExternalLink(url: bookATestForSomeoneElseLink)
    }
}
