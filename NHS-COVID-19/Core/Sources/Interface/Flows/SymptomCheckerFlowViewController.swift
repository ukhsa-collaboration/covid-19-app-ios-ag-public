//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public protocol SymptomCheckerFlowViewControllerInteracting {
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error>
    func invoke(interfaceSymptomsQuestionnaire: InterfaceSymptomsQuestionnaire?, isFeelingWell: Bool?) -> SymptomaticSummaryResult?
    func store(shouldTryToStayAtHome: Bool)
}

public class SymptomCheckerFlowViewController: BaseNavigationController {
    
    public typealias Interacting = SymptomCheckerFlowViewControllerInteracting
    
    fileprivate let interactor: Interacting
    
    fileprivate enum State: Equatable {
        case start
        case loaded
        case failedToLoad
        case howYouFeel
        case summary
        case tryToStayAtHome
        case normalActivities
    }
    
    @Published
    fileprivate var state: State = .start
    
    fileprivate var symptomsQuestionnaire = InterfaceSymptomsQuestionnaire(
        riskThreshold: 0.0,
        symptoms: [SymptomInfo](),
        cardinal: CardinalSymptomInfo(),
        noncardinal: CardinalSymptomInfo(),
        dateSelectionWindow: 0
    )
    
    fileprivate var doYouFeelWell: Bool? = nil
    
    private let currentDateProvider: DateProviding
    private let country: Country
    private let openURL: (URL) -> Void
    public var didCancel: (() -> Void)?
    public var finishFlow: (() -> Void)?
    
    private var cancellables = [AnyCancellable]()
    
    public init(_ interactor: Interacting, currentDateProvider: DateProviding, country: Country, openURL: @escaping (URL) -> Void) {
        self.interactor = interactor
        self.currentDateProvider = currentDateProvider
        self.country = country
        self.openURL = openURL
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
        if let viewControllerToPresent = viewControllers.first(where: { type(of: $0) == type(of: rootViewController(for: state)) }) {
            popToViewController(viewControllerToPresent, animated: true)
        } else {
            pushViewController(rootViewController(for: state), animated: state != .start)
        }
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            let interactor = LoadingViewControllerInteractor(navigationController: self)
            return LoadingViewController(interactor: interactor, title: localize(.your_symptoms_title))
        case .loaded:
            let interactor = YourSymptomsViewControllerInteractor(controller: self)
            return YourSymptomsViewController(symptomsQuestionnaire: symptomsQuestionnaire, interactor: interactor)
        case .failedToLoad:
            let interactor = LoadingErrorControllerInteractor(controller: self)
            return LoadingErrorViewController(interacting: interactor, title: localize(.diagnosis_questionnaire_title))
        case .howYouFeel:
            let interactor = HowDoYouFeelViewControllerInteractor(controller: self)
            return HowDoYouFeelViewController(interactor: interactor, doYouFeelWell: doYouFeelWell)
        case .summary:
            let interactor = CheckYourAnswersViewControllerInteractor(controller: self)
            return CheckYourAnswersViewController(symptomsQuestionnaire: symptomsQuestionnaire, doYouFeelWell: doYouFeelWell, interactor: interactor)
        case .tryToStayAtHome:
            let summaryResult: SymptomaticSummaryResult = .tryStayHome
            let interactor = SymptomaticCaseSummaryViewControllerInteractor(controller: self, openURL: self.openURL)
            return SymptomaticCaseSummaryViewController(interactor: interactor, adviseForSymptomaticCase: summaryResult)
        case .normalActivities:
            let summaryResult: SymptomaticSummaryResult = .continueWithNormalActivities
            let interactor = SymptomaticCaseSummaryViewControllerInteractor(controller: self, openURL: self.openURL)
            return SymptomaticCaseSummaryViewController(interactor: interactor, adviseForSymptomaticCase: summaryResult)
        }
    }
    
    func executeFetchQuestionnaire() {
        interactor.fetchQuestionnaire()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.state = .loaded
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

private class LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private weak var navigationController: SymptomCheckerFlowViewController?
    
    init(navigationController: SymptomCheckerFlowViewController?) {
        self.navigationController = navigationController
    }
    
    func didTapCancel() {
        navigationController?.didCancel?()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private struct LoadingErrorControllerInteractor: LoadingErrorViewController.Interacting {
    private weak var controller: SymptomCheckerFlowViewController?
    
    init(controller: SymptomCheckerFlowViewController?) {
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

private struct YourSymptomsViewControllerInteractor: YourSymptomsViewController.Interacting {
    
    private weak var controller: SymptomCheckerFlowViewController?
    
    init(controller: SymptomCheckerFlowViewController?) {
        self.controller = controller
    }
    
    public func didTapCancel() {
        controller?.didCancel?()
        controller?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapReportButton(hasNonCardinalSymptoms: Bool, hasCardinalSymptoms: Bool) {
        if let controller = controller {
            controller.state = .howYouFeel
        }
    }
}

private struct HowDoYouFeelViewControllerInteractor: HowDoYouFeelViewController.Interacting {
    
    private weak var controller: SymptomCheckerFlowViewController?
    
    init(controller: SymptomCheckerFlowViewController?) {
        self.controller = controller
    }
    
    func didTapContinueButton(_ doYouFeelWell: Bool) {
        controller?.doYouFeelWell = doYouFeelWell
        controller?.state = .summary
    }
    
    func didTapBackButton() {
        controller?.state = .loaded
    }
    
}

private struct CheckYourAnswersViewControllerInteractor: CheckYourAnswersViewController.Interacting {
    
    private weak var controller: SymptomCheckerFlowViewController?
    
    let firstChangeButtonId: String = "firstChangeButtonId"
    let secondChangeButtonId: String = "secondChangeButtonId"
    
    init(controller: SymptomCheckerFlowViewController?) {
        self.controller = controller
    }
    
    func changeYourSymptoms() {
        controller?.state = .loaded
    }
    
    func changeHowYouFeel() {
        controller?.state = .howYouFeel
    }
    
    func didTapBackButton() {
        controller?.state = .howYouFeel
    }
    
    func confirmAnswers() {
        if let adviceResult = controller?.interactor.invoke(
            interfaceSymptomsQuestionnaire: controller?.symptomsQuestionnaire,
            isFeelingWell: controller?.doYouFeelWell
        ) {
            switch adviceResult {
            case .tryStayHome:
                controller?.state = .tryToStayAtHome
            case .continueWithNormalActivities:
                controller?.state = .normalActivities
            }
            controller?.interactor.store(shouldTryToStayAtHome: adviceResult == .tryStayHome)
        }
    }
}

private struct SymptomaticCaseSummaryViewControllerInteractor: SymptomaticCaseSummaryViewController.Interacting {
    
    private weak var controller: SymptomCheckerFlowViewController?
    private let openURL: (URL) -> Void

    init(controller: SymptomCheckerFlowViewController?, openURL: @escaping (URL) -> Void) {
        self.controller = controller
        self.openURL = openURL
    }

    func didTapSymptomaticCase() {
        openURL(ExternalLink.didTapSymptomCheckerNormalActivities.url)
    }
    
    func didTapReturnHome() {
        controller?.finishFlow?()
        controller?.dismiss(animated: true, completion: nil)
    }
    
    func didTapCancel() {
        controller?.state = .summary
    }
    
    func didTapOnlineServicesLink() {
        openURL(ExternalLink.nhs111Online.url)
    }
    
    func didTapSymptomCheckerNormalActivities() {
        openURL(ExternalLink.didTapSymptomaticCase.url)
    }
}
