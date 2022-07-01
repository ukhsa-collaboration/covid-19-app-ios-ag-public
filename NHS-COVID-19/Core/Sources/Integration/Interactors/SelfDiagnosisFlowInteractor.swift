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
    let initialIsolationState: Domain.IsolationState

    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error> {
        selfDiagnosisManager.fetchQuestionnaire()
            .map { questionnaire in
                let symptomInfos: [SymptomInfo] = questionnaire.symptoms.map { symptom in
                    self.symptomMapper.interfaceSymptomFrom(domainSymptom: symptom)
                }
                return InterfaceSymptomsQuestionnaire(
                    riskThreshold: questionnaire.riskThreshold,
                    symptoms: symptomInfos,
                    cardinal: CardinalSymptomInfo(),
                    noncardinal: CardinalSymptomInfo(),
                    dateSelectionWindow: questionnaire.dateSelectionWindow,
                    isSymptomaticSelfIsolationForWalesEnabled: questionnaire.isSymptomaticSelfIsolationForWalesEnabled
                )
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }

    func advice(basedOn symptomsQuestionnaire: InterfaceSymptomsQuestionnaire, onsetDay: GregorianDay?, country: Country) -> SelfDiagnosisAdvice {
        let riskThreshold: Double = symptomsQuestionnaire.riskThreshold
        let symptoms: [SymptomInfo] = symptomsQuestionnaire.symptoms
        let selectedSymptoms = symptoms
            .filter(\.isConfirmed)
            .map(symptomMapper.domainSymptomFrom)
        let symptomaticSelfIsolationEnabled = !(country == .wales && !symptomsQuestionnaire.isSymptomaticSelfIsolationForWalesEnabled)

        let evaluation = selfDiagnosisManager.evaluate(
            selectedSymptoms: selectedSymptoms,
            onsetDay: onsetDay,
            threshold: riskThreshold,
            symptomaticSelfIsolationEnabled: symptomaticSelfIsolationEnabled
        )
        switch evaluation {
        case .noSymptoms:
            return .noSymptoms(.init(initialIsolationState))
        case .hasSymptoms(let isolation, let testState):
            let adviceDetails: SelfDiagnosisAdvice.HasSymptomsAdviceDetails = .init(isolation: isolation, testState: testState)
            if !symptomaticSelfIsolationEnabled
                && adviceDetails == .isolate(SelfDiagnosisAdvice.ExistingPositiveTestState.hasNoTests, endDate: isolation.endDate) {
                return .hasSymptoms(.followAdviceButNoIsolationNeeded)
            } else {
                return .hasSymptoms(adviceDetails)
            }
        }
    }

    var adviceWhenNoSymptomsAreReported: SelfDiagnosisAdvice {
        .noSymptoms(.init(initialIsolationState))
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

    func nhsGuidanceLinkTapped() {
        openURL(ExternalLink.nhsGuidance.url)
    }

    func gettingTestedLinkTapped() {
        openURL(ExternalLink.getTested.url)
    }

    func exposureFAQsLinkTapped() {
        openURL(ExternalLink.exposureFAQs.url)
    }

    func gettingTestedWalesLinkTapped() {
        openURL(ExternalLink.getTestedWalesLink.url)
    }

    func walesNHS111OnlineLinkTapped() {
        openURL(ExternalLink.walesNHS111OnlineLink.url)
    }

    func commonQuestionsLinkTapped() {
        openURL(ExternalLink.commonQuestionLink.url)
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

    init(_ isolationState: Domain.IsolationState) {
        switch isolationState {
        case .noNeedToIsolate:
            self = .noNeedToIsolate
        case .isolate(let isolation) where isolation.hasPositiveTestResult:
            self = .isolateForExistingPositiveTest
        case .isolate(let isolation):
            self = .isolateForUnspecifiedReason(endDate: isolation.endDate)
        }
    }

}

private extension SelfDiagnosisAdvice.HasSymptomsAdviceDetails {

    init(isolation: Isolation, testState: SelfDiagnosisEvaluation.ExistingPositiveTestState) {
        switch testState {
        case .hasNoTest:
            self = .isolate(.hasNoTests, endDate: isolation.endDate)
        case .hasTest(shouldChangeAdviceDueToSymptoms: true):
            self = .isolate(.hasTestsButShouldUseSymptoms, endDate: isolation.endDate)
        case .hasTest(shouldChangeAdviceDueToSymptoms: false):
            self = .followAdviceForExistingPositiveTest
        }
    }
}
