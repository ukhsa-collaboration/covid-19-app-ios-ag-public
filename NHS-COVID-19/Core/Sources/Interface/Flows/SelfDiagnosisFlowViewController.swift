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
}

public class SelfDiagnosisFlowViewController: UINavigationController {
    
    public typealias Interacting = SelfDiagnosisFlowViewControllerInteracting
    
    private let interactor: Interacting
    
    private enum State: Equatable {
        case start
        case loaded(Int?)
        case failedToLoad
        case reviewing
        case noSymptoms(currentIsolationState: IsolationState)
        case hasSymptoms(isolationEndDate: Date)
        case bookATest
    }
    
    @Published
    private var state: State = .start
    
    private var symptoms = [SymptomInfo]()
    private var dateSelectionWindow = 0
    private var initialIsolationState: IsolationState
    
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
        pushViewController(rootViewController(for: state), animated: state != .start)
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            return LoadingViewController(interactor: self, title: localize(.diagnosis_questionnaire_title))
        case .loaded(let symptomIndex):
            return SymptomListViewController(symptoms, symptomIndex: symptomIndex, interactor: self)
        case .failedToLoad:
            return LoadingErrorViewController(interacting: self, title: localize(.diagnosis_questionnaire_title))
        case .reviewing:
            return SymptomsReviewViewController(symptoms, dateSelectionWindow: dateSelectionWindow, interactor: self)
        case .noSymptoms(.notIsolating):
            return NoSymptomsViewController(interactor: self)
        case .noSymptoms(.isolating(_, let endDate)):
            let interactor = NoSymptomsIsolatingViewControllerInteractor(navigationController: self, didTapOnlineServicesLink: self.interactor.nhs111LinkTapped)
            return NoSymptomsIsolatingViewController(interactor: interactor, isolationEndDate: endDate)
        case .hasSymptoms(let isolationEndDate):
            return PositiveSymptomsViewController(interactor: self, isolationEndDate: isolationEndDate)
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

extension SelfDiagnosisFlowViewController: LoadingViewController.Interacting {
    public func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension SelfDiagnosisFlowViewController: LoadingErrorViewController.Interacting {
    public func didTapRetry() {
        executeFetchQuestionnaire()
    }
}

extension SelfDiagnosisFlowViewController: SymptomListViewController.Interacting {
    public func didTapReportButton() -> Result<Void, UIValidationError> {
        guard symptoms.contains(where: { $0.isConfirmed }) else {
            return .failure(.noSymptomSelected)
        }
        
        state = .reviewing
        return .success(())
    }
    
    public func didTapNoSymptomsButton() {
        state = .noSymptoms(currentIsolationState: initialIsolationState)
    }
}

extension SelfDiagnosisFlowViewController: NoSymptomsViewController.Interacting {
    public func didTapNHS111Link() {
        #warning("Do this properly")
        let url = URL(string: "https://111.nhs.uk/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    public func didTapReturnHome() {
        dismiss(animated: true, completion: nil)
    }
}

extension SelfDiagnosisFlowViewController: PositiveSymptomsViewController.Interacting {
    public func furtherAdviceLinkTapped() {
        interactor.furtherAdviceLinkTapped()
    }
    
    public func didTapBookTest() {
        state = .bookATest
    }
}

extension SelfDiagnosisFlowViewController: SymptomsReviewViewController.Interacting {
    public func changeSymptomAnswer(index: Int) {
        state = .loaded(index)
    }
    
    public func confirmSymptoms(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, UIValidationError> {
        if selectedDay == nil, !hasCheckedNoDate {
            return .failure(.neitherDateNorNoDateCheckSet)
        } else {
            if let isolationEndDate = interactor.evaluateSymptoms(symptoms: symptoms, onsetDay: selectedDay) {
                state = .hasSymptoms(isolationEndDate: isolationEndDate)
            } else {
                state = .noSymptoms(currentIsolationState: initialIsolationState)
            }
            return .success(())
        }
    }
}
