//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import Localization
import UIKit

class PostAcknowledgementViewController: UIViewController {
    fileprivate enum InterfaceState: Equatable {
        #warning("Refactor `homeOrPostTestResultAction` and separate into multiple states")
        /// Either the 'home screen' or actions people need to do after receiving a test result, e.g.:
        /// * booking a follow-up test (if they've had an unconfirmed test result)
        /// * sharing their keys
        case homeOrPostTestResultAction
        case thankYouCompleted
        case bookATest
        case warnAndBookATest
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var setNeedsUpdate: Bool = true
    
    fileprivate var interfaceState: InterfaceState = .homeOrPostTestResultAction {
        didSet {
            setNeedsInterfaceUpdate()
        }
    }
    
    private let context: RunningAppContext
    private let shouldShowLanguageSelectionScreen: Bool
    private let clearBookATest: () -> Void
    fileprivate let clearWarnAndBookATest: () -> Void
    private let clearContactTracingHub: () -> Void
    private let clearLocalInfoScreen: () -> Void
    private let showContactTracingHub: CurrentValueSubject<Bool, Never>
    private let showLocalInfoScreen: CurrentValueSubject<Bool, Never>
    
    private var diagnosisKeySharer: DiagnosisKeySharer? {
        didSet {
            setNeedsInterfaceUpdate()
        }
    }
    
    private var isFollowUpTestRequired: Bool = false {
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
        showWarnAndBookATest: CurrentValueSubject<Bool, Never>,
        showContactTracingHub: CurrentValueSubject<Bool, Never>,
        showLocalInfoScreen: CurrentValueSubject<Bool, Never>
    ) {
        self.context = context
        self.shouldShowLanguageSelectionScreen = shouldShowLanguageSelectionScreen
        self.showContactTracingHub = showContactTracingHub
        self.showLocalInfoScreen = showLocalInfoScreen
        
        clearBookATest = { showBookATest.value = false }
        clearWarnAndBookATest = { showWarnAndBookATest.value = false }
        
        // todo; we pass the subject down anyway - why do we need these?
        clearContactTracingHub = { showContactTracingHub.value = false }
        clearLocalInfoScreen = { showLocalInfoScreen.value = false }
        
        super.init(nibName: nil, bundle: nil)
        
        showBookATest
            .removeDuplicates()
            .receive(on: UIScheduler.shared)
            .sink { [weak self] showBookATest in
                #warning("Avoid publishing values and find a better way to do this.")
                guard self?.interfaceState != .thankYouCompleted else { return }
                guard self?.interfaceState != .warnAndBookATest else { return }
                self?.interfaceState = showBookATest ? .bookATest : .homeOrPostTestResultAction
            }.store(in: &cancellables)
        
        showWarnAndBookATest
            .removeDuplicates()
            .receive(on: UIScheduler.shared)
            .sink { [weak self] showWarnAndBookATest in
                #warning("Avoid this pattern and find a better way to do this.")
                guard self?.interfaceState != .thankYouCompleted else { return }
                guard self?.interfaceState != .bookATest else { return }
                self?.interfaceState = showWarnAndBookATest ? .warnAndBookATest : .homeOrPostTestResultAction
            }.store(in: &cancellables)
        
        context.diagnosisKeySharer
            .receive(on: UIScheduler.shared)
            .sink(receiveValue: { [weak self] diagnosisKeySharer in
                #warning("Avoid this pattern and find a better way to do this.")
                guard self?.interfaceState != .warnAndBookATest else { return }
                guard self?.interfaceState != .bookATest else { return }
                self?.diagnosisKeySharer = diagnosisKeySharer
            })
            .store(in: &cancellables)
        
        context.virologyTestingManager
            .isFollowUpTestRequired()
            .receive(on: UIScheduler.shared)
            .sink(receiveValue: { [weak self] isFollowUpTestRequired in
                self?.isFollowUpTestRequired = isFollowUpTestRequired
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
        case .homeOrPostTestResultAction:
            content = homeOrPostResultActionViewController()
            
        case .thankYouCompleted:
            content = ThankYouViewController.viewController(
                for: isFollowUpTestRequired ? .stillNeedToBookATest : .completed,
                interactor: ThankYouViewControllerInteractor { [weak self] in
                    self?.interfaceState = .homeOrPostTestResultAction
                }
            )
            
        case .bookATest:
            content = bookATestViewController()
            
        case .warnAndBookATest:
            content = warnAndBookATestViewController()
        }
    }
    
    private func homeOrPostResultActionViewController() -> UIViewController {
        if let diagnosisKeySharer = diagnosisKeySharer,
            let shareFlowType = SendKeysFlowViewController.ShareFlowType(
                hasFinishedInitialKeySharingFlow: diagnosisKeySharer.hasFinishedInitialKeySharingFlow,
                hasTriggeredReminderNotification: diagnosisKeySharer.hasTriggeredReminderNotification
            ) {
            return sendKeysViewController(diagnosisKeySharer, shareFlowType: shareFlowType)
        }
        
        if isFollowUpTestRequired {
            return bookAFollowUpTestController()
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
                        self?.interfaceState = .homeOrPostTestResultAction
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
        
        let localInfoBannerViewModel = context.localInformation
            .combineLatest(context.postcodeInfo)
            .map { (localInfo, postcodeInfo) -> LocalInformationBanner.ViewModel? in
                guard let localInfo = localInfo,
                    let message = localInfo.info?.translations(for: currentLocaleIdentifier())
                else { return nil }
                
                guard let headingText = message.head,
                    let renderableBlocks = message.renderable()
                else { return nil }
                
                let postcode = postcodeInfo?.postcode.value ?? ""
                let localAuthority = localInfo.localAuthority?.name ?? ""
                
                #warning("Postcode and local authority placeholder replacement should be done in the model layer")
                let paragraphs = renderableBlocks.map { renderableBlock in
                    LocalInformationViewController.ViewModel.Paragraph(
                        text: renderableBlock.text?.stringByReplacing(postcode: postcode, localAuthority: localAuthority),
                        link: renderableBlock.url
                    )
                }
                
                let replacementHeadingText = headingText.stringByReplacing(postcode: postcode, localAuthority: localAuthority)
                
                return LocalInformationBanner.ViewModel(
                    text: replacementHeadingText,
                    localInfoScreenViewModel: .init(header: replacementHeadingText, body: paragraphs)
                )
            }
            .property(initialValue: nil)
        
        let animationDisabled = NotificationCenter.default.publisher(
            for: UIAccessibility.reduceMotionStatusDidChangeNotification
        ).map { _ in UIAccessibility.isReduceMotionEnabled }
            .prepend(UIAccessibility.isReduceMotionEnabled)
            .combineLatest(context.homeAnimationsStore.homeAnimationsEnabled) { reduceMotion, animationsEnabled -> Bool in
                guard !reduceMotion else { return true }
                return !animationsEnabled
            }.receive(on: RunLoop.main)
            .property(initialValue: UIAccessibility.isReduceMotionEnabled)
        
        let isolationViewModel = RiskLevelIndicator.ViewModel(
            isolationState: context.isolationState
                .mapToInterface(with: context.currentDateProvider)
                .property(initialValue: .notIsolating),
            paused: context.exposureNotificationStateController.isEnabledPublisher.map { !$0 }.property(initialValue: false),
            animationDisabled: animationDisabled
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
        
        let showWarnAndBookATestFlow = context.isolationState.combineLatest(didRecentlyVisitSevereRiskyVenue) { state, didRecentlyVisitSevereRiskyVenue in
            var showWarnAndBookATestFlow: Bool = false
            switch state {
            case .isolate(let isolation) where isolation.isIndexCase:
                showWarnAndBookATestFlow = false
            default:
                showWarnAndBookATestFlow = true
            }
            return showWarnAndBookATestFlow && didRecentlyVisitSevereRiskyVenue != nil
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
            localInfoBannerViewModel: localInfoBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: context.exposureNotificationStateController.isEnabledPublisher,
            showOrderTestButton: showOrderTestButton,
            showWarnAndBookATestFlow: showWarnAndBookATestFlow,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationEnabled,
            showFinancialSupportButton: showFinancialSupportButton,
            recordSelectedIsolationPaymentsButton: { Metrics.signpost(.selectedIsolationPaymentsButton) },
            country: country,
            shouldShowLanguageSelectionScreen: shouldShowLanguageSelectionScreen,
            showContactTracingHub: showContactTracingHub,
            clearContactTracingHub: clearContactTracingHub,
            showLocalInfoScreen: showLocalInfoScreen,
            clearLocalInfoScreen: clearLocalInfoScreen
        )
    }
    
    private func bookAFollowUpTestController() -> UIViewController {
        let interactor = BookAFollowUpTestInteractor(
            didTapPrimaryButton: { [weak self] in
                self?.context.virologyTestingManager.didClearBookFollowUpTest()
                self?.interfaceState = .bookATest
            },
            didTapCancel: { [weak self] in
                self?.context.virologyTestingManager.didClearBookFollowUpTest()
                self?.interfaceState = .homeOrPostTestResultAction
            },
            openURL: context.openURL
        )
        
        let bookAFollowUpTestViewController = BookAFollowUpTestViewController(interactor: interactor)
        
        return BaseNavigationController(rootViewController: bookAFollowUpTestViewController)
    }
    
    private func bookATestViewController() -> UIViewController {
        
        let navigationVC = BaseNavigationController()
        
        let virologyInteractor = VirologyTestingFlowInteractor(
            virologyTestOrderInfoProvider: context.virologyTestingManager,
            openURL: context.openURL,
            acknowledge: { [weak self] in
                DispatchQueue.onMain {
                    self?.clearBookATest()
                    self?.interfaceState = .homeOrPostTestResultAction
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
    
    private func warnAndBookATestViewController() -> UIViewController {
        let navigationVC = BaseNavigationController()
        let checkSymptomsInteractor = TestCheckSymptomsInteractor(
            didTapYes: { [weak self] in
                guard let self = self else { return }
                Metrics.signpost(.selectedHasSymptomsM2Journey)
                let vc = WrappingViewController {
                    SelfDiagnosisOrderFlowState.makeState(
                        context: self.context,
                        acknowledge: { [weak self] in
                            self?.clearWarnAndBookATest()
                        }
                    )
                    .map { state in
                        switch state {
                        case .selfDiagnosis(let interactor):
                            let selfDiagnosisFlowVC = SelfDiagnosisFlowViewController(interactor, currentDateProvider: self.context.currentDateProvider)
                            selfDiagnosisFlowVC.finishFlow = { [weak self] in
                                self?.clearWarnAndBookATest()
                            }
                            return selfDiagnosisFlowVC
                        case .testOrdering(let interactor):
                            return VirologyTestingFlowViewController(interactor)
                        }
                    }
                }
                vc.modalPresentationStyle = .overFullScreen
                navigationVC.present(vc, animated: true, completion: nil)
            },
            didTapNo: { [weak self] in
                guard let self = self else { return }
                Metrics.signpost(.selectedHasNoSymptomsM2Journey)
                let interactor = BookARapidTestInfoInteractor(viewController: self, openURL: self.context.openURL)
                let vc = BookARapidTestInfoViewController(interactor: interactor)
                navigationVC.pushViewController(vc, animated: true)
            }
        )
        let checkSymptomsVC = TestCheckSymptomsViewController.viewController(
            for: .warnAndBookATest,
            interactor: checkSymptomsInteractor,
            shouldHaveCancelButton: true,
            shouldConfirmCancel: true
        )
        checkSymptomsVC.didCancel = { [weak self] in
            self?.clearWarnAndBookATest()
        }
        navigationVC.viewControllers = [checkSymptomsVC]
        return navigationVC
    }
}

private struct ThankYouViewControllerInteractor: ThankYouViewController.Interacting {
    var didTapButton: () -> Void
    
    func action() {
        didTapButton()
    }
}

private struct TestCheckSymptomsInteractor: TestCheckSymptomsViewController.Interacting {
    var didTapYes: () -> Void
    var didTapNo: () -> Void
}

private struct BookARapidTestInfoInteractor: BookARapidTestInfoViewController.Interacting {
    private weak var viewController: PostAcknowledgementViewController?
    public let openURL: (URL) -> Void
    
    init(viewController: PostAcknowledgementViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }
    
    func didTapAlreadyHaveATest() {
        Metrics.signpost(.selectedHasLFDTestM2Journey)
        viewController?.clearWarnAndBookATest()
    }
    
    func didTapBookATest() {
        Metrics.signpost(.selectedLFDTestOrderingM2Journey)
        openURL(ExternalLink.getTested.url)
        viewController?.clearWarnAndBookATest()
    }
}
