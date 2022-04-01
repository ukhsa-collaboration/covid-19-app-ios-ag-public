//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import Localization
import UIKit

public enum ContactCaseResultInterfaceState: Equatable {
    case underAgeLimit(secondTestAdviceDate: Date?)
    case fullyVaccinated(secondTestAdviceDate: Date?)
    case medicallyExempt
    case startIsolation(endDate: Date, exposureDate: Date, secondTestAdviceDate: Date?)
    case continueIsolation(endDate: Date, secondTestAdviceDate: Date?)
}

class PostAcknowledgementViewController: UIViewController {
    // This is call UITriggered state for now as this is called from inside integration
    // and only one of them can be active at one time
    enum UITriggeredInterfaceState: Equatable {
        case showBookATest
        case showWarnAndBookATest
        case showContactCaseResult(ContactCaseResultInterfaceState)
        case thankYou
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var setNeedsUpdate: Bool = true
    
    fileprivate var interfaceState: PostAcknowledgmentState = .home {
        didSet {
            setNeedsInterfaceUpdate()
        }
    }
    
    private let context: RunningAppContext
    private let shouldShowLanguageSelectionScreen: Bool
    fileprivate let showUIState: CurrentValueSubject<UITriggeredInterfaceState?, Never>
    fileprivate let bluetoothOffAcknowledgementNeeded: AnyPublisher<Bool, Never>
    fileprivate let bluetoothOffAcknowledgedCallback: () -> Void
    private let showNotificationScreen: CurrentValueSubject<NotificationInterfaceState?, Never>
    
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
        showUIState: CurrentValueSubject<UITriggeredInterfaceState?, Never>,
        showNotificationScreen: CurrentValueSubject<NotificationInterfaceState?, Never>
    ) {
        self.context = context
        self.shouldShowLanguageSelectionScreen = shouldShowLanguageSelectionScreen
        self.showUIState = showUIState
        self.showNotificationScreen = showNotificationScreen
        bluetoothOffAcknowledgementNeeded = context.bluetoothOffAcknowledgementNeeded
        bluetoothOffAcknowledgedCallback = context.bluetoothOffAcknowledgedCallback
        
        super.init(nibName: nil, bundle: nil)
        
        PostAcknowledgmentState.makePostAcknowledgmentState(
            showUIState: showUIState,
            bluetoothOffAcknowledgementNeeded: bluetoothOffAcknowledgementNeeded,
            diagnosisKeySharer: context.diagnosisKeySharer,
            virologyTestingManager: context.virologyTestingManager
        )
        .sink { [weak self] in self?.interfaceState = $0 }
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
        content = makeContentViewController()
    }
    
    private func makeContentViewController() -> UIViewController {
        switch interfaceState {
        case .bluetoothOff:
            let interactor = BluetoothDisabledWarningInteractor(viewController: self, openSettings: context.openSettings)
            return BluetoothDisabledWarningViewController.viewController(for: .onboarding, interactor: interactor, country: context.country.currentValue)
        case .home:
            return homeViewController()
        case .keySharing(let diagnosisKeySharer, let shareFlowType):
            return sendKeysViewController(diagnosisKeySharer, shareFlowType: shareFlowType)
        case .followUpTest:
            return bookAFollowUpTestController()
        case .thankYou(let viewType):
            return ThankYouViewController.viewController(
                for: viewType,
                interactor: ThankYouViewControllerInteractor { [weak self] in
                    self?.showUIState.send(nil)
                }
            )
        case .bookATest:
            return bookATestViewController()
        case .warnAndBookATest:
            return warnAndBookATestViewController()
        case .contactCase(let state):
            switch state {
            case .underAgeLimit(let secondTestAdviceDate):
                switch context.country.currentValue {
                case .wales:
                    return ContactCaseNoIsolationUnderAgeLimitWalesViewController(
                        interactor: ContactCaseNoIsolationUnderAgeLimitInteractor(viewController: self, openURL: context.openURL),
                        secondTestAdviceDate: secondTestAdviceDate
                    )
                case .england:
                    return ContactCaseNoIsolationUnderAgeLimitEnglandViewController(
                        interactor: ContactCaseNoIsolationUnderAgeLimitInteractor(viewController: self, openURL: context.openURL)
                    )
                }
            case .fullyVaccinated(let secondTestAdviceDate):
                switch context.country.currentValue {
                case .wales:
                    return ContactCaseNoIsolationFullyVaccinatedWalesViewController(
                        interactor: ContactCaseNoIsolationFullyVaccinatedInteractor(viewController: self, openURL: context.openURL),
                        secondTestAdviceDate: secondTestAdviceDate
                    )
                case .england:
                    return ContactCaseNoIsolationFullyVaccinatedEnglandViewController(
                        interactor: ContactCaseNoIsolationFullyVaccinatedInteractor(viewController: self, openURL: context.openURL)
                    )
                }
            case .medicallyExempt:
                return ContactCaseNoIsolationMedicallyExemptViewController(
                    interactor: ContactCaseNoIsolationMedicallyExemptInteractor(viewController: self, openURL: context.openURL)
                )
            case .startIsolation(let endDate, let exposureDate, let secondTestAdviceDate):
                switch context.country.currentValue {
                case .wales:
                    return ContactCaseStartIsolationWalesViewController(
                        interactor: ContactCaseStartIsolationInteractor(
                            viewController: self,
                            openURL: context.openURL,
                            testBookingAction: .orderLateralFlow
                        ),
                        isolationEndDate: endDate,
                        exposureDate: exposureDate,
                        secondTestAdviceDate: secondTestAdviceDate,
                        isolationPeriod: context.contactCaseIsolationDuration.currentValue,
                        currentDateProvider: context.currentDateProvider
                    )
                case .england:
                    return ContactCaseStartIsolationEnglandViewController(
                        interactor: ContactCaseStartIsolationInteractor(
                            viewController: self,
                            openURL: context.openURL,
                            testBookingAction: .bookPCR
                        ),
                        isolationEndDate: endDate,
                        exposureDate: exposureDate,
                        isolationPeriod: context.contactCaseIsolationDuration.currentValue, currentDateProvider: context.currentDateProvider
                    )
                }
            case .continueIsolation(let date, let secondTestAdviceDate):
                return ContactCaseContinueIsolationViewController(
                    interactor: ContactCaseContinueIsolationInteractor(viewController: self, openURL: context.openURL),
                    secondTestAdviceDate: secondTestAdviceDate,
                    isolationEndDate: date,
                    currentDateProvider: context.currentDateProvider
                )
            }
        }
    }
    
    private func sendKeysViewController(_ diagnosisKeySharer: DiagnosisKeySharer, shareFlowType: SendKeysFlowViewController.ShareFlowType) -> UIViewController {
        let interactor = SendKeysFlowViewControllerInteractor(
            diagnosisKeySharer: diagnosisKeySharer,
            didReceiveResult: { [weak self] value in
                DispatchQueue.onMain {
                    if value == .sent {
                        self?.showUIState.send(.thankYou)
                    } else {
                        self?.showUIState.send(nil)
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
        
        let riskLevelBannerViewModel = context.postcodeInfo
            .map { postcodeInfo -> AnyPublisher<RiskLevelBanner.ViewModel?, Never> in
                guard let postcodeInfo = postcodeInfo else { return Just(nil).eraseToAnyPublisher() }
                return postcodeInfo.risk
                    .map { riskLevel -> RiskLevelBanner.ViewModel? in
                        guard let riskLevel = riskLevel else { return nil }
                        return RiskLevelBanner.ViewModel(
                            postcode: postcodeInfo.postcode,
                            localAuthority: postcodeInfo.localAuthority,
                            risk: riskLevel
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
            animationDisabled: animationDisabled, bluetoothOff: context.bluetoothOff.interfaceProperty, country: context.country.interfaceProperty
        )
        
        let didRecentlyVisitSevereRiskyVenue = context.checkInContext?.recentlyVisitedSevereRiskyVenue ?? DomainProperty<GregorianDay?>.constant(nil)
        
        let showOrderTestButton = context.shouldShowBookALabTest
            .combineLatest(didRecentlyVisitSevereRiskyVenue) { shouldShowBookALabTest, didRecentlyVisitSevereRiskyVenue in
                shouldShowBookALabTest || didRecentlyVisitSevereRiskyVenue != nil
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
            bluetoothOff: context.bluetoothOff.eraseToAnyPublisher(),
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
            showNotificationScreen: showNotificationScreen,
            shouldShowLocalStats: context.shouldShowLocalStats
        )
    }
    
    private func bookAFollowUpTestController() -> UIViewController {
        let interactor = BookAFollowUpTestInteractor(
            didTapPrimaryButton: { [weak self] in
                self?.context.virologyTestingManager.didClearBookFollowUpTest()
                self?.showUIState.send(.showBookATest)
            },
            didTapCancel: { [weak self] in
                self?.context.virologyTestingManager.didClearBookFollowUpTest()
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
                    self?.showUIState.send(nil)
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
                            self?.showUIState.send(nil)
                        }
                    )
                    .map { state in
                        switch state {
                        case .selfDiagnosis(let interactor):
                            let selfDiagnosisFlowVC = SelfDiagnosisFlowViewController(interactor, currentDateProvider: self.context.currentDateProvider, country: self.context.country.currentValue)
                            selfDiagnosisFlowVC.finishFlow = { [weak self] in
                                self?.showUIState.send(nil)
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
            self?.showUIState.send(nil)
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
        viewController?.showUIState.send(nil)
    }
    
    func didTapBookATest() {
        Metrics.signpost(.selectedLFDTestOrderingM2Journey)
        openURL(ExternalLink.getTested.url)
        viewController?.showUIState.send(nil)
    }
}

private struct ContactCaseNoIsolationUnderAgeLimitInteractor: ContactCaseNoIsolationUnderAgeLimitEnglandViewController.Interacting {
    
    private weak var viewController: PostAcknowledgementViewController?
    private let openURL: (URL) -> Void
    
    init(viewController: PostAcknowledgementViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }
    
    func didTapBookAFreeTest() {
        viewController?.showUIState.send(.showBookATest)
    }
    
    func didTapBackToHome() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapCancel() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapGuidanceLink() {
        openURL(ExternalLink.nhsGuidance.url)
    }
    
    func didTapCommonQuestionsLink() {
        openURL(ExternalLink.faq.url)
    }
    
    func didTapReadGuidanceForContacts() {
        openURL(ExternalLink.guidanceForContactsInEngland.url)
        viewController?.showUIState.send(nil)
    }
    
}

private struct ContactCaseNoIsolationFullyVaccinatedInteractor: ContactCaseNoIsolationFullyVaccinatedEnglandViewController.Interacting {
    private weak var viewController: PostAcknowledgementViewController?
    private let openURL: (URL) -> Void
    
    init(viewController: PostAcknowledgementViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }
    
    func didTapBookAFreeTest() {
        viewController?.showUIState.send(.showBookATest)
    }
    
    func didTapBackToHome() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapCancel() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapGuidanceLink() {
        openURL(ExternalLink.nhsGuidance.url)
    }
    
    func didTapCommonQuestionsLink() {
        openURL(ExternalLink.faq.url)
    }
    
    func didTapReadGuidanceForContacts() {
        openURL(ExternalLink.guidanceForContactsInEngland.url)
        viewController?.showUIState.send(nil)
    }
}

private struct ContactCaseNoIsolationMedicallyExemptInteractor: ContactCaseNoIsolationMedicallyExemptViewController.Interacting {
    private weak var viewController: PostAcknowledgementViewController?
    private let openURL: (URL) -> Void
    
    init(viewController: PostAcknowledgementViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }
    
    func didTapBookAFreeTest() {
        viewController?.showUIState.send(.showBookATest)
    }
    
    func didTapBackToHome() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapCancel() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapGuidanceLink() {
        openURL(ExternalLink.nhsGuidance.url)
    }
    
    func didTapCommonQuestionsLink() {
        openURL(ExternalLink.faq.url)
    }
    
    func didTapReadGuidanceForContacts() {
        openURL(ExternalLink.guidanceForContactsInEngland.url)
        viewController?.showUIState.send(nil)
    }
}

private struct ContactCaseStartIsolationInteractor: ContactCaseStartIsolationInteracting {
    enum TestOrderingAction {
        case bookPCR
        case orderLateralFlow
    }
    
    private weak var viewController: PostAcknowledgementViewController?
    private let openURL: (URL) -> Void
    private let testOrderingAction: TestOrderingAction
    
    init(viewController: PostAcknowledgementViewController?,
         openURL: @escaping (URL) -> Void,
         testBookingAction: TestOrderingAction) {
        self.viewController = viewController
        self.openURL = openURL
        testOrderingAction = testBookingAction
    }
    
    func didTapGetTestButton() {
        switch testOrderingAction {
        case .bookPCR:
            viewController?.showUIState.send(.showBookATest)
        case .orderLateralFlow:
            openURL(ExternalLink.getRapidTestsAsymptomaticWales.url)
            viewController?.showUIState.send(nil)
        }
    }
    
    func didTapBackToHome() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapCancel() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapGuidanceLink() {
        openURL(ExternalLink.nhsGuidance.url)
    }
}

private struct ContactCaseContinueIsolationInteractor: ContactCaseContinueIsolationViewController.Interacting {
    private weak var viewController: PostAcknowledgementViewController?
    private let openURL: (URL) -> Void
    
    init(viewController: PostAcknowledgementViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }
    
    func didTapBackToHome() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapCancel() {
        viewController?.showUIState.send(nil)
    }
    
    func didTapGuidanceLink() {
        openURL(ExternalLink.nhsGuidance.url)
    }
}

private struct BluetoothDisabledWarningInteractor: BluetoothDisabledWarningViewController.Interacting {
    private weak var viewController: PostAcknowledgementViewController?
    private let openSettings: () -> Void
    
    init(viewController: PostAcknowledgementViewController?, openSettings: @escaping () -> Void) {
        self.viewController = viewController
        self.openSettings = openSettings
    }
    
    func didTapSettings() {
        openSettings()
    }
    
    func didTapContinue() {
        viewController?.bluetoothOffAcknowledgedCallback()
    }
}
