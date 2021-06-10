//
// Copyright © 2021 DHSC. All rights reserved.
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
    #warning("Use domain model")
    // We directly import `Domain` here. There's no need to go via an `Interface` type.
    let initialIsolationState: Interface.IsolationState
    
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
    
    func advice(basedOn symptoms: [SymptomInfo], onsetDay: GregorianDay?, riskThreshold: Double) -> SelfDiagnosisAdvice {
        #warning("Simplify this.")
        // Start pushing down use of the unstructured `(Date?, Bool?)` type and eventually remove it.
        let state = evaluateSymptoms(riskThreshold: riskThreshold, symptoms: symptoms, onsetDay: onsetDay)
        if let isolationEndDate = state.0 {
            switch state.1 {
            case .none:
                return .hasSymptoms(.isolate(.hasNoTests, endDate: isolationEndDate))
            case .some(true):
                return .hasSymptoms(.isolate(.hasTestsButShouldUseSymptoms, endDate: isolationEndDate))
            case .some(false):
                return .hasSymptoms(.followAdviceForExistingPositiveTest)
            }
        } else {
            return .noSymptoms(.init(initialIsolationState))
        }
    }
    
    var adviceWhenNoSymptomsAreReported: SelfDiagnosisAdvice {
        .noSymptoms(.init(initialIsolationState))
    }
    
    private func evaluateSymptoms(riskThreshold: Double, symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> (Date?, Bool?) {
        let isolationState = _evaluateSymptoms(riskThreshold: riskThreshold, symptoms: symptoms, onsetDay: onsetDay)
        switch isolationState.0 {
        case .isolate(let isolation):
            return (isolation.endDate, isolationState.1)
        case .noNeedToIsolate:
            return (nil, isolationState.1)
        }
    }
    
    private func _evaluateSymptoms(riskThreshold: Double, symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> (Domain.IsolationState, Bool?) {
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
    
    func gettingTestedLinkTapped() {
        openURL(ExternalLink.getTested.url)
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

private extension SelfDiagnosisAdvice.NoSymptomsAdviceDetails {
    
    init(_ isolationState: Interface.IsolationState) {
        switch isolationState {
        case .notIsolating:
            self = .noNeedToIsolate
        case .isolating(_, _, _, hasPositiveTest: true):
            self = .isolateForExistingPositiveTest
        case .isolating(_, _, let endDate, hasPositiveTest: false):
            self = .isolateForUnspecifiedReason(endDate: endDate)
        }
    }
    
}
