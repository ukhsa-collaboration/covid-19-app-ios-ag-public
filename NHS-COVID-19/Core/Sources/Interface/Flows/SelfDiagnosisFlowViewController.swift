//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public enum UIValidationError: Error {
    case noSymptomSelected
    case noCardinalSymptomSelected
    case noNonCardinalSymptomSelected
    case neitherCardinalNorNonCardinalSymptomsSelected
    case neitherDateNorNoDateCheckSet
}

public enum SelfDiagnosisAdvice: Equatable {

    public enum ExistingPositiveTestState: Equatable {
        case hasNoTests
        case hasTestsButShouldUseSymptoms
    }

    public enum HasSymptomsAdviceDetails: Equatable {
        case followAdviceForExistingPositiveTest
        case isolate(ExistingPositiveTestState, endDate: Date)
        case followAdviceButNoIsolationNeeded
    }

    public enum NoSymptomsAdviceDetails: Equatable {
        case noNeedToIsolate
        case isolateForExistingPositiveTest
        case isolateForUnspecifiedReason(endDate: Date)
    }

    case noSymptoms(NoSymptomsAdviceDetails)
    case hasSymptoms(HasSymptomsAdviceDetails)
}

public protocol SelfDiagnosisFlowViewControllerInteracting: BookATestInfoViewControllerInteracting {
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error>

    func advice(basedOn symptomsQuestionnaire: InterfaceSymptomsQuestionnaire, onsetDay: GregorianDay?, country: Country) -> SelfDiagnosisAdvice

    var adviceWhenNoSymptomsAreReported: SelfDiagnosisAdvice { get }

    func openTestkitOrder()
    func furtherAdviceLinkTapped()
    func nhs111LinkTapped()
    func nhsGuidanceLinkTapped()
    func gettingTestedLinkTapped()
    func exposureFAQsLinkTapped()
    func walesNHS111OnlineLinkTapped()
    func commonQuestionsLinkTapped()
    func gettingTestedWalesLinkTapped()
}

public class SelfDiagnosisFlowViewController: BaseNavigationController {

    public typealias Interacting = SelfDiagnosisFlowViewControllerInteracting

    fileprivate let interactor: Interacting

    fileprivate enum State: Equatable {
        case start
        case loaded(scrollToSymptomAtIndex: Int?)
        case failedToLoad
        case reviewing
        case advice(SelfDiagnosisAdvice)
        case bookATest
        case guidance
    }

    @Published
    fileprivate var state: State = .start

    fileprivate var symptomsQuestionnaire = InterfaceSymptomsQuestionnaire(
        riskThreshold: 0.0,
        symptoms: [SymptomInfo](),
        cardinal: CardinalSymptomInfo(),
        noncardinal: CardinalSymptomInfo(),
        dateSelectionWindow: 0,
        isSymptomaticSelfIsolationForWalesEnabled: false
    )

    private let currentDateProvider: DateProviding
    fileprivate let country: Country
    public var didCancel: (() -> Void)?
    public var finishFlow: (() -> Void)?

    private var cancellables = [AnyCancellable]()

    public init(_ interactor: Interacting, currentDateProvider: DateProviding, country: Country) {
        self.interactor = interactor
        self.currentDateProvider = currentDateProvider
        self.country = country
        super.init()

        monitorState()
        executeFetchQuestionnaire()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func monitorState() {
        $state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }

    private func update(for state: State) {
        pushViewController(rootViewController(for: state), animated: state != .start)
    }

    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            let interactor = LoadingViewControllerInteractor(navigationController: self)
            return LoadingViewController(interactor: interactor, title: localize(.diagnosis_questionnaire_title))
        case .loaded(let symptomIndex):
            let interactor = SymptomListViewControllerInteractor(
                controller: self
            )
            return SymptomListViewController(symptoms: symptomsQuestionnaire.symptoms, scrollToSymptomAt: symptomIndex, interactor: interactor)
        case .failedToLoad:
            let interactor = LoadingErrorControllerInteractor(controller: self)
            return LoadingErrorViewController(interacting: interactor, title: localize(.diagnosis_questionnaire_title))
        case .reviewing:
            let interactor = SymptomsReviewViewControllerInteractor(controller: self)
            return SymptomsReviewViewController(symptomsQuestionnaire: symptomsQuestionnaire, currentDateProvider: currentDateProvider, interactor: interactor)
        case .advice(let advice):
            return viewController(for: advice)
        case .bookATest:
            return BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: false)
        case .guidance:
            let interactor = GuidanceForSymptomaticCasesEnglandViewControllerInteractor(controller: self)
            return GuidanceForSymptomaticCasesEnglandViewController(interactor: interactor)
        }
    }

    private func viewController(for advice: SelfDiagnosisAdvice) -> UIViewController {
        switch advice {
        case .noSymptoms(.noNeedToIsolate):
                let interactor = NoSymptomsViewControllerInteractor(controller: self)
                return NoSymptomsViewController(interactor: interactor)
        case .noSymptoms(.isolateForExistingPositiveTest):
            let interactor = SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteractor(
                navigationController: self,
                didTapOnlineServicesLink: self.interactor.nhs111LinkTapped
            )
            return SelfDiagnosisAfterPositiveTestIsolatingViewController(interactor: interactor, symptomState: .noSymptoms)
        case .noSymptoms(.isolateForUnspecifiedReason(let endDate)):
            let interactor = NoSymptomsIsolatingViewControllerInteractor(navigationController: self, didTapOnlineServicesLink: self.interactor.nhs111LinkTapped)
            return NoSymptomsIsolatingViewController(interactor: interactor, isolationEndDate: endDate, dateProvider: currentDateProvider)
        case .hasSymptoms(.isolate(.hasNoTests, let isolationEndDate)):
            switch country {
            case .england:
                let interactor = IsolationAdviceForSymptomaticCasesEnglandViewControllerInteractor(controller: self)
                return IsolationAdviceForSymptomaticCasesEnglandViewController(interactor: interactor)
            case .wales:
                let interactor = PositiveSymptomsViewControllerInteractor(controller: self)
                return PositiveSymptomsViewController(interactor: interactor, isolationEndDate: isolationEndDate, currentDateProvider: currentDateProvider)
            }
        case .hasSymptoms(.isolate(.hasTestsButShouldUseSymptoms, let isolationEndDate)):
            let interactor = SymptomsAfterPositiveTestViewControllerInteractor(
                navigationController: self,
                didTapOnlineServicesLink: self.interactor.nhs111LinkTapped
            )
            return SymptomsAfterPositiveTestViewController(interactor: interactor, isolationEndDate: isolationEndDate, currentDateProvider: currentDateProvider)
        case .hasSymptoms(.followAdviceForExistingPositiveTest):
            let interactor = SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteractor(
                navigationController: self,
                didTapOnlineServicesLink: self.interactor.nhs111LinkTapped
            )
            return SelfDiagnosisAfterPositiveTestIsolatingViewController(interactor: interactor, symptomState: .discardSymptoms)
        case .hasSymptoms(.followAdviceButNoIsolationNeeded):
            let interactor = PositiveSymptomsNoIsolationViewControllerInteractor(controller: self)
            return PositiveSymptomsNoIsolationViewController(interactor: interactor)
        }
    }

    func executeFetchQuestionnaire() {
        state = .start

        interactor.fetchQuestionnaire()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.state = .loaded(scrollToSymptomAtIndex: nil)
                    case .failure:
                        self?.state = .failedToLoad
                    }
                },
                receiveValue: { [weak self] symptomsQuestionnaire in
                    self?.symptomsQuestionnaire = symptomsQuestionnaire
                }
            )
            .store(in: &cancellables)
    }
}

private struct NoSymptomsIsolatingViewControllerInteractor: NoSymptomsIsolatingViewController.Interacting {
    private weak var navigationController: SelfDiagnosisFlowViewController?

    private var _didTapOnlineServicesLink: () -> Void

    init(navigationController: SelfDiagnosisFlowViewController?, didTapOnlineServicesLink: @escaping () -> Void) {
        self.navigationController = navigationController
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }

    func didTapReturnHome() {
        navigationController?.finishFlow?()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func didTapCancel() {
        navigationController?.finishFlow?()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func didTapOnlineServicesLink() {
        _didTapOnlineServicesLink()
    }

}

private class LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private weak var navigationController: SelfDiagnosisFlowViewController?

    init(navigationController: SelfDiagnosisFlowViewController?) {
        self.navigationController = navigationController
    }

    func didTapCancel() {
        navigationController?.didCancel?()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private struct LoadingErrorControllerInteractor: LoadingErrorViewController.Interacting {
    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    func didTapCancel() {
        controller?.didCancel?()
        controller?.dismiss(animated: true, completion: nil)
    }

    public func didTapRetry() {
        controller?.executeFetchQuestionnaire()
    }
}

private struct SymptomListViewControllerInteractor: SymptomListViewController.Interacting {
    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    public func didTapCancel() {
        controller?.didCancel?()
        controller?.dismiss(animated: true, completion: nil)
    }

    public func didTapReportButton() -> Result<Void, UIValidationError> {
        guard let controller = controller else {
            return .success(())
        }

        guard controller.symptomsQuestionnaire.symptoms.contains(where: { $0.isConfirmed }) else {
            return .failure(.noSymptomSelected)
        }

        controller.state = .reviewing
        return .success(())
    }

    public func didTapNoSymptomsButton() {
        guard let controller = controller else { return }
        controller.state = .advice(controller.interactor.adviceWhenNoSymptomsAreReported)
    }

}

private struct NoSymptomsViewControllerInteractor: NoSymptomsViewController.Interacting {

    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    public func didTapNHS111Link() {
        controller?.interactor.nhs111LinkTapped()
    }

    public func didTapGettingTestedLink() {
        controller?.interactor.gettingTestedLinkTapped()
    }

    public func didTapReturnHome() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }
}

private struct PositiveSymptomsViewControllerInteractor: PositiveSymptomsViewController.Interacting {

    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    public func didTapCancel() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }

    public func furtherAdviceLinkTapped() {
        controller?.interactor.nhs111LinkTapped()
    }

    public func didTapGetRapidLateralFlowTest() {
        controller?.interactor.gettingTestedWalesLinkTapped()
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }

    public func exposureFAQsLinkTapped() {
        controller?.interactor.exposureFAQsLinkTapped()
    }
}

private struct IsolationAdviceForSymptomaticCasesEnglandViewControllerInteractor: IsolationAdviceForSymptomaticCasesEnglandViewController.Interacting {

    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    func didTapContinue() {
        controller?.state = .guidance
    }

}

private struct GuidanceForSymptomaticCasesEnglandViewControllerInteractor: GuidanceForSymptomaticCasesEnglandViewController.Interacting {

    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    func didTapCommonQuestionsLink() {
        controller?.interactor.exposureFAQsLinkTapped()
    }

    func didTapNHSOnlineLink() {
        controller?.interactor.nhs111LinkTapped()
    }

    func didTapBackToHome() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true)
    }
}

private struct SymptomsReviewViewControllerInteractor: SymptomsReviewViewController.Interacting {

    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    public func changeSymptomAnswer(index: Int) {
        controller?.state = .loaded(scrollToSymptomAtIndex: index)
    }

    public var hideDateInfoBox: Bool {
        guard let isSymptomaticSelfIsolationForWalesEnabled = controller?.symptomsQuestionnaire.isSymptomaticSelfIsolationForWalesEnabled else {
            return false
        }

        if !isSymptomaticSelfIsolationForWalesEnabled && controller?.country == .wales {
            return true
        } else {
            return false
        }
    }

    public func confirmSymptoms(riskThreshold: Double, selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, UIValidationError> {
        guard let controller = controller else {
            return .success(())
        }
        if selectedDay == nil, !hasCheckedNoDate {
            return .failure(.neitherDateNorNoDateCheckSet)
        } else {
            let advice = controller.interactor.advice(
                basedOn: controller.symptomsQuestionnaire,
                onsetDay: selectedDay,
                country: controller.country
            )
            controller.state = .advice(advice)
            return .success(())
        }
    }
}

private struct SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteractor: SelfDiagnosisAfterPositiveTestIsolatingViewController.Interacting {

    private weak var navigationController: SelfDiagnosisFlowViewController?

    private var _didTapOnlineServicesLink: () -> Void

    init(navigationController: SelfDiagnosisFlowViewController?, didTapOnlineServicesLink: @escaping () -> Void) {
        self.navigationController = navigationController
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }

    func didTapReturnHome() {
        navigationController?.finishFlow?()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func didTapNHS111Link() {
        _didTapOnlineServicesLink()
    }

}

private struct SymptomsAfterPositiveTestViewControllerInteractor: SymptomsAfterPositiveTestViewController.Interacting {

    private weak var navigationController: SelfDiagnosisFlowViewController?

    private var _didTapOnlineServicesLink: () -> Void

    init(navigationController: SelfDiagnosisFlowViewController?, didTapOnlineServicesLink: @escaping () -> Void) {
        self.navigationController = navigationController
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }

    func didTapReturnHome() {
        navigationController?.finishFlow?()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func didTapOnlineServicesLink() {
        _didTapOnlineServicesLink()
    }
}

private struct PositiveSymptomsNoIsolationViewControllerInteractor: PositiveSymptomsNoIsolationViewController.Interacting {
    private weak var controller: SelfDiagnosisFlowViewController?

    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }

    public func didTapCancel() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }

    func commonQuestionsLinkTapped() {
        controller?.interactor.commonQuestionsLinkTapped()
    }

    func nhs111OnlineLinkTapped() {
        controller?.interactor.walesNHS111OnlineLinkTapped()
    }

    func backHomeButtonTapped() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }
}

