//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import UIKit

class PostAcknowledgementViewController: UIViewController {
    fileprivate enum InterfaceState: Equatable {
        case home
        case thankYouCompleted
        case bookATest
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var setNeedsUpdate: Bool = true
    
    fileprivate var interfaceState: InterfaceState = .home {
        didSet {
            setNeedsInterfaceUpdate()
        }
    }
    
    private let context: RunningAppContext
    private let shouldShowLanguageSelectionScreen: Bool
    private let clearBookATest: () -> Void
    private let clearContactTracingHub: () -> Void
    private let showContactTracingHub: CurrentValueSubject<Bool, Never>
    
    private var diagnosisKeySharer: DiagnosisKeySharer? {
        didSet {
            setNeedsInterfaceUpdate()
        }
    }
    
    private var content: UIViewController? {
        didSet {
            oldValue?.remove()
            if let content = content {
                addFilling(content)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
    
    init(
        context: RunningAppContext,
        shouldShowLanguageSelectionScreen: Bool,
        showBookATest: CurrentValueSubject<Bool, Never>,
        showContactTracingHub: CurrentValueSubject<Bool, Never>
    ) {
        self.context = context
        self.shouldShowLanguageSelectionScreen = shouldShowLanguageSelectionScreen
        self.showContactTracingHub = showContactTracingHub
        
        clearBookATest = { showBookATest.value = false }
        clearContactTracingHub = { showContactTracingHub.value = false }
        
        super.init(nibName: nil, bundle: nil)
        
        showBookATest
            .removeDuplicates()
            .sink { [weak self] showBookATest in
                guard self?.interfaceState != .thankYouCompleted else { return }
                DispatchQueue.onMain {
                    self?.interfaceState = showBookATest ? .bookATest : .home
                }
            }.store(in: &cancellables)
        
        context.diagnosisKeySharer
            .sink(receiveValue: { [weak self] diagnosisKeySharer in
                DispatchQueue.onMain {
                    self?.diagnosisKeySharer = diagnosisKeySharer
                }
            })
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateIfNeeded()
    }
    
    private func setNeedsInterfaceUpdate() {
        setNeedsUpdate = true
        if isViewLoaded {
            view.setNeedsLayout()
        }
    }
    
    private func updateIfNeeded() {
        
        guard isViewLoaded, setNeedsUpdate else { return }
        setNeedsUpdate = false
        
        switch interfaceState {
        case .home:
            content = homeOrSendKeysViewController()
        case .thankYouCompleted:
            content = ThankYouViewController.viewController(
                for: .completed,
                interactor: ThankYouViewControllerInteractor(viewController: self)
            )
        case .bookATest:
            content = bookATestViewController()
        }
    }
    
    private func homeOrSendKeysViewController() -> UIViewController {
        
        if let diagnosisKeySharer = diagnosisKeySharer,
            let shareFlowType = SendKeysFlowViewController.ShareFlowType(
                hasFinishedInitialKeySharingFlow: diagnosisKeySharer.hasFinishedInitialKeySharingFlow,
                hasTriggeredReminderNotification: diagnosisKeySharer.hasTriggeredReminderNotification
            ) {
            return sendKeysViewController(diagnosisKeySharer, shareFlowType: shareFlowType)
        }
        
        return homeViewController()
    }
    
    private func sendKeysViewController(_ diagnosisKeySharer: DiagnosisKeySharer, shareFlowType: SendKeysFlowViewController.ShareFlowType) -> UIViewController {
        
        let interactor = SendKeysFlowViewControllerInteractor(
            diagnosisKeySharer: diagnosisKeySharer,
            didReceiveResult: { [weak self] value in
                DispatchQueue.onMain {
                    if value == .sent {
                        self?.interfaceState = .thankYouCompleted
                    } else {
                        self?.interfaceState = .home
                    }
                }
            }
        )
        
        return SendKeysFlowViewController(
            interactor: interactor,
            shareFlowType: shareFlowType
        )
    }
    
    private func homeViewController() -> UIViewController {
        
        let interactor = HomeFlowViewControllerInteractor(
            context: context,
            currentDateProvider: context.currentDateProvider
        )
        
        let shouldShowMassTestingLink = context.country.map { country in
            country == .england
        }.interfaceProperty
        
        let riskLevelBannerViewModel = context.postcodeInfo
            .map { postcodeInfo -> AnyPublisher<RiskLevelBanner.ViewModel?, Never> in
                guard let postcodeInfo = postcodeInfo else { return Just(nil).eraseToAnyPublisher() }
                return postcodeInfo.risk
                    .map { riskLevel -> RiskLevelBanner.ViewModel? in
                        guard let riskLevel = riskLevel else { return nil }
                        return RiskLevelBanner.ViewModel(
                            postcode: postcodeInfo.postcode,
                            localAuthority: postcodeInfo.localAuthority,
                            risk: riskLevel,
                            shouldShowMassTestingLink: shouldShowMassTestingLink
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .property(initialValue: nil)
        
        let isolationViewModel = RiskLevelIndicator.ViewModel(
            isolationState: context.isolationState
                .mapToInterface(with: context.currentDateProvider)
                .property(initialValue: .notIsolating),
            paused: context.exposureNotificationStateController.isEnabledPublisher.map { !$0 }.property(initialValue: false)
        )
        
        let didRecentlyVisitSevereRiskyVenue = context.checkInContext?.recentlyVisitedSevereRiskyVenue ?? DomainProperty<GregorianDay?>.constant(nil)
        
        let showOrderTestButton = context.isolationState.combineLatest(didRecentlyVisitSevereRiskyVenue) { state, didRecentlyVisitSevereRiskyVenue in
            var shouldShowBookTestButton: Bool = false
            switch state {
            case .isolate:
                shouldShowBookTestButton = true
            default:
                shouldShowBookTestButton = false
            }
            return shouldShowBookTestButton || didRecentlyVisitSevereRiskyVenue != nil
        }
        .property(initialValue: false)
        
        let shouldShowSelfDiagnosis = context.isolationState.map { state in
            if case .isolate(let isolation) = state { return isolation.canFillQuestionnaire }
            return true
        }
        .property(initialValue: false)
        
        let userNotificationEnabled = context.exposureNotificationReminder.isNotificationAuthorized.property(initialValue: false)
        
        let showFinancialSupportButton = context.isolationPaymentState.map { isolationPaymentState -> Bool in
            switch isolationPaymentState {
            case .disabled: return false
            case .enabled: return true
            }
        }.interfaceProperty
        
        let country = context.country.property(initialValue: context.country.currentValue)
        
        return HomeFlowViewController(
            interactor: interactor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: context.exposureNotificationStateController.isEnabledPublisher,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationEnabled,
            showFinancialSupportButton: showFinancialSupportButton,
            recordSelectedIsolationPaymentsButton: { Metrics.signpost(.selectedIsolationPaymentsButton) },
            country: country,
            shouldShowLanguageSelectionScreen: shouldShowLanguageSelectionScreen,
            showContactTracingHub: showContactTracingHub,
            clearContactTracingHub: clearContactTracingHub
        )
    }
    
    private func bookATestViewController() -> UIViewController {
        
        let navigationVC = BaseNavigationController()
        
        let virologyInteractor = VirologyTestingFlowInteractor(
            virologyTestOrderInfoProvider: context.virologyTestingManager,
            openURL: context.openURL,
            acknowledge: { [weak self] in
                DispatchQueue.onMain {
                    self?.clearBookATest()
                    self?.interfaceState = .home
                }
            }
        )
        
        let bookATestInfoInteractor = BookATestInfoViewControllerInteractor(
            didTapBookATest: {
                let virologyFlowVC = VirologyTestingFlowViewController(virologyInteractor)
                navigationVC.present(virologyFlowVC, animated: true)
            },
            openURL: context.openURL
        )
        
        let bookATestInfoVC = BookATestInfoViewController(interactor: bookATestInfoInteractor, shouldHaveCancelButton: true)
        bookATestInfoVC.didCancel = virologyInteractor.acknowledge
        navigationVC.viewControllers = [bookATestInfoVC]
        return navigationVC
    }
}

private struct ThankYouViewControllerInteractor: ThankYouViewController.Interacting {
    weak var viewController: PostAcknowledgementViewController?
    
    func action() {
        viewController?.interfaceState = .home
    }
}
