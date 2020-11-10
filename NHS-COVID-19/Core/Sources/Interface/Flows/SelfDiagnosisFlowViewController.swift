//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public enum UIValidationError: Error {
    case noSymptomSelected
    case neitherDateNorNoDateCheckSet
}

public protocol SelfDiagnosisFlowViewControllerInteracting: BookATestInfoViewControllerInteracting {
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error>
    func evaluateSymptoms(symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Date?
    
    func openTestkitOrder()
    func furtherAdviceLinkTapped()
    func nhs111LinkTapped()
    func exposureFAQsLinkTapped()
}

public class SelfDiagnosisFlowViewController: UINavigationController {
    
    public typealias Interacting = SelfDiagnosisFlowViewControllerInteracting
    
    fileprivate let interactor: Interacting
    
    fileprivate enum State: Equatable {
        case start
        case loaded(Int?)
        case failedToLoad
        case reviewing
        case noSymptoms(currentIsolationState: IsolationState)
        case hasSymptoms(isolationEndDate: Date)
        case bookATest
    }
    
    @Published
    fileprivate var state: State = .start
    
    fileprivate var symptoms = [SymptomInfo]()
    private var dateSelectionWindow = 0
    fileprivate var initialIsolationState: IsolationState
    
    private var cancellables = [AnyCancellable]()
    
    public init(_ interactor: Interacting, initialIsolationState: IsolationState) {
        self.interactor = interactor
        self.initialIsolationState = initialIsolationState
        
        super.init(nibName: nil, bundle: nil)
        
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
        viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
        pushViewController(rootViewController(for: state), animated: state != .start)
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            let interactor = LoadingViewControllerInteractor(navigationController: self)
            return LoadingViewController(interactor: interactor, title: localize(.diagnosis_questionnaire_title))
        case .loaded(let symptomIndex):
            let interactor = SymptomListViewControllerInteractor(controller: self)
            return SymptomListViewController(symptoms, symptomIndex: symptomIndex, interactor: interactor)
        case .failedToLoad:
            let interactor = LoadingErrorControllerInteractor(controller: self)
            return LoadingErrorViewController(interacting: interactor, title: localize(.diagnosis_questionnaire_title))
        case .reviewing:
            let interactor = SymptomsReviewViewControllerInteractor(controller: self)
            return SymptomsReviewViewController(symptoms, dateSelectionWindow: dateSelectionWindow, interactor: interactor)
        case .noSymptoms(.notIsolating):
            let interactor = NoSymptomsViewControllerInteractor(controller: self)
            return NoSymptomsViewController(interactor: interactor)
        case .noSymptoms(.isolating(_, _, let endDate)):
            let interactor = NoSymptomsIsolatingViewControllerInteractor(navigationController: self, didTapOnlineServicesLink: self.interactor.nhs111LinkTapped)
            return NoSymptomsIsolatingViewController(interactor: interactor, isolationEndDate: endDate)
        case .hasSymptoms(let isolationEndDate):
            let interactor = PositiveSymptomsViewControllerInteractor(controller: self)
            return PositiveSymptomsViewController(interactor: interactor, isolationEndDate: isolationEndDate)
        case .bookATest:
            return BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: false)
        }
    }
    
    func executeFetchQuestionnaire() {
        state = .start
        
        interactor.fetchQuestionnaire()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.state = .loaded(nil)
                    case .failure:
                        self?.state = .failedToLoad
                    }
                },
                receiveValue: { [weak self] symptomsQuestionnaire in
                    self?.symptoms = symptomsQuestionnaire.symptoms
                    self?.dateSelectionWindow = symptomsQuestionnaire.dateSelectionWindow
                }
            )
            .store(in: &cancellables)
    }
}

private struct NoSymptomsIsolatingViewControllerInteractor: NoSymptomsIsolatingViewController.Interacting {
    private weak var navigationController: UINavigationController?
    
    private var _didTapOnlineServicesLink: () -> Void
    
    init(navigationController: UINavigationController?, didTapOnlineServicesLink: @escaping () -> Void) {
        self.navigationController = navigationController
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }
    
    func didTapReturnHome() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func didTapOnlineServicesLink() {
        _didTapOnlineServicesLink()
    }
    
}

private class LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private struct LoadingErrorControllerInteractor: LoadingErrorViewController.Interacting {
    private weak var controller: SelfDiagnosisFlowViewController?
    
    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }
    
    func didTapCancel() {
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
        controller?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapReportButton() -> Result<Void, UIValidationError> {
        guard let controller = controller else {
            return .success(())
        }
        
        guard controller.symptoms.contains(where: { $0.isConfirmed }) else {
            return .failure(.noSymptomSelected)
        }
        
        controller.state = .reviewing
        return .success(())
    }
    
    public func didTapNoSymptomsButton() {
        guard let controller = controller else { return }
        controller.state = .noSymptoms(currentIsolationState: controller.initialIsolationState)
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
    
    public func didTapReturnHome() {
        controller?.dismiss(animated: true, completion: nil)
    }
}

private struct PositiveSymptomsViewControllerInteractor: PositiveSymptomsViewController.Interacting {
    
    private weak var controller: SelfDiagnosisFlowViewController?
    
    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }
    
    public func didTapCancel() {
        controller?.dismiss(animated: true, completion: nil)
    }
    
    public func furtherAdviceLinkTapped() {
        controller?.interactor.nhs111LinkTapped()
    }
    
    public func didTapBookTest() {
        controller?.state = .bookATest
    }
    
    public func exposureFAQsLinkTapped() {
        controller?.interactor.exposureFAQsLinkTapped()
    }
}

private struct SymptomsReviewViewControllerInteractor: SymptomsReviewViewController.Interacting {
    
    private weak var controller: SelfDiagnosisFlowViewController?
    
    init(controller: SelfDiagnosisFlowViewController?) {
        self.controller = controller
    }
    
    public func changeSymptomAnswer(index: Int) {
        controller?.state = .loaded(index)
    }
    
    public func confirmSymptoms(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, UIValidationError> {
        guard let controller = controller else {
            return .success(())
        }
        if selectedDay == nil, !hasCheckedNoDate {
            return .failure(.neitherDateNorNoDateCheckSet)
        } else {
            if let isolationEndDate = controller.interactor.evaluateSymptoms(symptoms: controller.symptoms, onsetDay: selectedDay) {
                controller.state = .hasSymptoms(isolationEndDate: isolationEndDate)
            } else {
                controller.state = .noSymptoms(currentIsolationState: controller.initialIsolationState)
            }
            return .success(())
        }
    }
}
