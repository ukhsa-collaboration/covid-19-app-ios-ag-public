//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public enum NotificationInterfaceState {
    case contactTracingHub
    case localInfo

}

public protocol HomeFlowViewControllerInteracting {
    func makeDiagnosisViewController() -> UIViewController?
    func openAdvice()
    func openOrderAFreeTestingKit()
    func makeCheckInViewController() -> UIViewController?
    func makeSelfIsolationHubViewController(
        flowController: UINavigationController?,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>,
        showWarnAndBookATestFlow: InterfaceProperty<Bool>,
        recordSelectedIsolationPaymentsButton: @escaping () -> Void
    ) -> UIViewController?
    func makeGuidanceHubEnglandViewController(flowController: UINavigationController?) -> UIViewController?
    func makeGuidanceHubWalesViewController(flowController: UINavigationController?) -> UIViewController?
    func makeTestingInformationViewController(flowController: UINavigationController?, showWarnAndBookATestFlow: InterfaceProperty<Bool>) -> UIViewController?
    func makeFinancialSupportViewController(flowController: UINavigationController?) -> UIViewController?
    func makeLinkTestResultViewController() -> UIViewController?
    func makeContactTracingHubViewController(flowController: UINavigationController?, exposureNotificationsEnabled: InterfaceProperty<Bool>, exposureNotificationsToggleAction: @escaping (Bool) -> Void, userNotificationsEnabled: InterfaceProperty<Bool>) -> UIViewController
    func makeLocalInfoScreenViewController(viewModel: LocalInformationViewController.ViewModel, interactor: LocalInformationViewController.Interacting) -> UIViewController
    func makeBluetoothDisabledWarningViewController(flowController: UINavigationController?) -> UIViewController
    func removeDeliveredLocalInfoNotifications()
    func makeTestingHubViewController(flowController: UINavigationController?, showOrderTestButton: InterfaceProperty<Bool>, showFindOutAboutTestingButton: InterfaceProperty<Bool>, showWarnAndBookATestFlow: InterfaceProperty<Bool>) -> UIViewController
    func makeLocalCovidStatsViewController(flowController: UINavigationController?) -> UIViewController
    func getMyDataViewModel() -> MyDataViewController.ViewModel
    func getMyAreaViewModel() -> MyAreaTableViewController.ViewModel
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn)
    var shouldShowCheckIn: Bool { get }
    var shouldShowTestingForCOVID19: Bool { get }
    var shouldShowSelfIsolation: Bool { get }
    var shouldShowGuidanceHub: Bool { get }
    func openTearmsOfUseLink()
    func openPrivacyLink()
    func openFAQ()
    func openAccessibilityStatementLink()
    func openHowThisAppWorksLink()
    func openWebsiteLinkfromRisklevelInfoScreen(url: URL)
    func openWebsiteLinkfromLocalInfoScreen(url: URL)
    func openProvideFeedbackLink()
    func openDownloadNHSAppLink()
    func deleteAppData()
    func updateVenueHistories(deleting venueHistory: VenueHistory) -> [VenueHistory]
    func makeLocalAuthorityOnboardingInteractor() -> LocalAuthorityFlowViewController.Interacting
    func getCurrentLocaleConfiguration() -> InterfaceProperty<LocaleConfiguration>
    func storeNewLanguage(_ localeConfiguration: LocaleConfiguration) -> Void
    func getVenueHistoryViewModel() -> VenueHistoryViewController.ViewModel
    func getHomeAnimationsViewModel() -> HomeAnimationsViewModel
    func recordDidTapLocalInfoBannerMetric()
    func openReadLatestGovernmentGuidanceLink()
    func openFindYourLocalAuthorityLink()
    func didTapGetIsolationNoteLink()
    func openSettings()

    func openGuidanceHubEnglandLink1()
    func openGuidanceHubEnglandLink2()
    func openGuidanceHubEnglandLink3()
    func openGuidanceHubEnglandLink4()
    func openGuidanceHubEnglandLink5()
    func openGuidanceHubEnglandLink6()
    func openGuidanceHubEnglandLink7()
    func openGuidanceHubEnglandLink8()

    func openGuidanceHubWalesLink1()
    func openGuidanceHubWalesLink2()
    func openGuidanceHubWalesLink3()
    func openGuidanceHubWalesLink4()
    func openGuidanceHubWalesLink5()
    func openGuidanceHubWalesLink6()
    func openGuidanceHubWalesLink7()
    func openGuidanceHubWalesLink8()

    var newLabelForLongCovidCurrentCountryState: NewLabelState { get }
}

public enum ExposureNotificationReminderIn: Int, CaseIterable {
    case fourHours = 4
    case eightHours = 8
    case twelveHours = 12
}

public class HomeFlowViewController: BaseNavigationController {

    public typealias Interacting = HomeFlowViewControllerInteracting

    private let interactor: Interacting
    private var cancellables = [AnyCancellable]()

    // Allows the UI to update immediately until a genuine value has been published by the model
    private let optimisiticExposureNotificationsEnabled = CurrentValueSubject<Bool?, Never>(nil)
    private let exposureNotificationsEnabled: InterfaceProperty<Bool>
    private let userNotificationsEnabled: InterfaceProperty<Bool>
    private let showNotificationScreen: CurrentValueSubject<NotificationInterfaceState?, Never>
    private var localInformationInteractor: LocalInformationInteractor?
    private var localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>?
    private var newLabelForLongCovidCurrentCountryState: NewLabelState

    public init(
        interactor: Interacting,
        bluetoothOff: AnyPublisher<Bool, Never>,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        showWarnAndBookATestFlow: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>,
        recordSelectedIsolationPaymentsButton: @escaping () -> Void,
        country: InterfaceProperty<Country>,
        shouldShowLanguageSelectionScreen: Bool,
        showNotificationScreen: CurrentValueSubject<NotificationInterfaceState?, Never>,
        shouldShowLocalStats: Bool,
        newLabelForLongCovidCurrentCountryState: NewLabelState
    ) {
        self.interactor = interactor

        self.exposureNotificationsEnabled = optimisiticExposureNotificationsEnabled
            .combineLatest(exposureNotificationsEnabled) { $0 ?? $1 }
            .removeDuplicates()
            .property(initialValue: false)

        self.userNotificationsEnabled = userNotificationsEnabled
        self.showNotificationScreen = showNotificationScreen
        self.newLabelForLongCovidCurrentCountryState = interactor.newLabelForLongCovidCurrentCountryState

        super.init()

        let aboutThisAppInteractor = AboutThisAppInteractor(flowController: self, interactor: interactor)
        let settingsInteractor = SettingsInteractor(flowController: self, interactor: interactor)
        let riskLevelInteractor = RiskLevelInfoInteractor(interactor: interactor)
        let localInformationInteractor = LocalInformationInteractor(flowController: self, flowInteractor: interactor)

        self.localInformationInteractor = localInformationInteractor
        self.localInfoBannerViewModel = localInfoBannerViewModel

        let showFindOutAboutTestingButton = showOrderTestButton.map { !$0 }

        let homeViewControllerInteractor = HomeViewControllerInteractor(
            flowController: self,
            flowInteractor: interactor,
            bluetoothOff: bluetoothOff,
            riskLevelInteractor: riskLevelInteractor,
            localInformationInteractor: localInformationInteractor,
            aboutThisAppInteractor: aboutThisAppInteractor,
            settingsInteractor: settingsInteractor,
            recordSelectedIsolationPaymentsButton: recordSelectedIsolationPaymentsButton,
            userNotificationsEnabled: userNotificationsEnabled,
            exposureNotificationsEnabled: exposureNotificationsEnabled.property(initialValue: false),
            exposureNotificationsToggleAction: exposureNotificationSwitchValueChanged,
            showOrderTestButton: showOrderTestButton,
            showFindOutAboutTestingButton: showFindOutAboutTestingButton,
            showWarnAndBookATestFlow: showWarnAndBookATestFlow,
            showFinancialSupportButton: showFinancialSupportButton
        )

        let showLanguageSelectionScreen: () -> Void = {
            let viewController = SettingsViewController(viewModel: SettingsViewController.ViewModel(), interacting: settingsInteractor)
            self.pushViewController(viewController, animated: true)
            if let languageViewController = settingsInteractor.makeLanguageSelectionViewController() {
                self.pushViewController(languageViewController, animated: false)
            }
        }

        let rootViewController = HomeViewController(
            interactor: homeViewControllerInteractor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            localInfoBannerViewModel: localInfoBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: self.exposureNotificationsEnabled,
            exposureNotificationsToggleAction: exposureNotificationSwitchValueChanged,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationsEnabled,
            showFinancialSupportButton: showFinancialSupportButton,
            country: country,
            showLanguageSelectionScreen: shouldShowLanguageSelectionScreen ? showLanguageSelectionScreen : nil,
            showNotificationScreen: {
                switch showNotificationScreen.value {
                case .contactTracingHub: self.checkAndShowContactTracingHub()
                case .localInfo: self.checkAndShowLocalInfoScreen()
                case .none: showNotificationScreen.send(nil)
                }
            },
            shouldShowLocalStats: shouldShowLocalStats
        )

        viewControllers = [rootViewController]

        showNotificationScreen
            .removeDuplicates()
            .filterNil()
            .receive(on: UIScheduler.shared)
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .contactTracingHub: self.checkAndShowContactTracingHub()
                case .localInfo: self.checkAndShowLocalInfoScreen()
                }
            }).store(in: &cancellables)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func exposureNotificationSwitchValueChanged(_ isOn: Bool) {
        optimisiticExposureNotificationsEnabled.send(isOn)
        interactor.setExposureNotifcationEnabled(isOn)
            .sink(receiveCompletion: { [weak self] _ in
                // Reset ready for next time
                self?.optimisiticExposureNotificationsEnabled.send(nil)
            }, receiveValue: {})
            .store(in: &cancellables)
    }

    private func checkAndShowContactTracingHub() {
        showNotificationScreen.send(nil)
        guard presentedViewController == nil, viewControllers.count == 1 else { return }

        let vc = interactor.makeContactTracingHubViewController(
            flowController: self,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            exposureNotificationsToggleAction: exposureNotificationSwitchValueChanged,
            userNotificationsEnabled: userNotificationsEnabled
        )
        pushViewController(vc, animated: true)
    }

    private func checkAndShowLocalInfoScreen() {
        showNotificationScreen.send(nil)
        localInfoBannerViewModel?.$wrappedValue
            .compactMap { $0?.localInfoScreenViewModel }
            .first()
            .receive(on: UIScheduler.shared)
            .sink { [weak self] viewModel in
                guard let self = self else { return }

                guard self.presentedViewController == nil, self.viewControllers.count == 1 else { return }

                guard let localInformationInteractor = self.localInformationInteractor else { return }

                let vc = self.interactor.makeLocalInfoScreenViewController(
                    viewModel: viewModel,
                    interactor: localInformationInteractor
                )
                let navigationController = BaseNavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .overFullScreen

                self.interactor.removeDeliveredLocalInfoNotifications()

                self.present(navigationController, animated: true)
            }
            .store(in: &cancellables)
    }
}

private struct HomeViewControllerInteractor: HomeViewController.Interacting {
    private weak var flowController: UINavigationController?
    private let flowInteractor: HomeFlowViewController.Interacting
    private let bluetoothOff: AnyPublisher<Bool, Never>
    private let riskLevelInteractor: RiskLevelInfoViewController.Interacting
    private let localInformationInteractor: LocalInformationViewController.Interacting
    private let aboutThisAppInteractor: AboutThisAppViewController.Interacting
    private let settingsInteractor: SettingsViewController.Interacting
    private let recordSelectedIsolationPaymentsButton: () -> Void
    private let userNotificationsEnabled: InterfaceProperty<Bool>
    private let exposureNotificationsEnabled: InterfaceProperty<Bool>
    private let exposureNotificationsToggleAction: (Bool) -> Void
    private let showOrderTestButton: InterfaceProperty<Bool>
    private let showFindOutAboutTestingButton: InterfaceProperty<Bool>
    private let showWarnAndBookATestFlow: InterfaceProperty<Bool>
    private let showFinancialSupportButton: InterfaceProperty<Bool>

    init(
        flowController: UINavigationController,
        flowInteractor: HomeFlowViewController.Interacting,
        bluetoothOff: AnyPublisher<Bool, Never>,
        riskLevelInteractor: RiskLevelInfoViewController.Interacting,
        localInformationInteractor: LocalInformationViewController.Interacting,
        aboutThisAppInteractor: AboutThisAppViewController.Interacting,
        settingsInteractor: SettingsViewController.Interacting,
        recordSelectedIsolationPaymentsButton: @escaping () -> Void,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void,
        showOrderTestButton: InterfaceProperty<Bool>,
        showFindOutAboutTestingButton: InterfaceProperty<Bool>,
        showWarnAndBookATestFlow: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>
    ) {
        self.flowController = flowController
        self.flowInteractor = flowInteractor
        self.bluetoothOff = bluetoothOff
        self.riskLevelInteractor = riskLevelInteractor
        self.localInformationInteractor = localInformationInteractor
        self.aboutThisAppInteractor = aboutThisAppInteractor
        self.settingsInteractor = settingsInteractor
        self.recordSelectedIsolationPaymentsButton = recordSelectedIsolationPaymentsButton
        self.userNotificationsEnabled = userNotificationsEnabled
        self.exposureNotificationsEnabled = exposureNotificationsEnabled
        self.exposureNotificationsToggleAction = exposureNotificationsToggleAction
        self.showOrderTestButton = showOrderTestButton
        self.showFindOutAboutTestingButton = showFindOutAboutTestingButton
        self.showWarnAndBookATestFlow = showWarnAndBookATestFlow
        self.showFinancialSupportButton = showFinancialSupportButton
    }

    public func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel) {
        let viewController = RiskLevelInfoViewController(viewModel: viewModel, interactor: riskLevelInteractor)
        let navigationController = BaseNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen

        flowController?.present(navigationController, animated: true)
    }

    public func didTapLocalInfoBanner(viewModel: LocalInformationViewController.ViewModel) {

        // todo; this is identical to the code in HomeFlowViewController
        let viewController = flowInteractor.makeLocalInfoScreenViewController(
            viewModel: viewModel,
            interactor: localInformationInteractor
        )
        let navigationController = BaseNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen

        flowInteractor.removeDeliveredLocalInfoNotifications()

        flowController?.present(navigationController, animated: true)
        flowInteractor.recordDidTapLocalInfoBannerMetric()
    }

    public func didTapDiagnosisButton() {
        guard let viewController = flowInteractor.makeDiagnosisViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        flowController?.present(viewController, animated: true)
    }

    public func didTapCheckInButton() {
        guard let viewController = flowInteractor.makeCheckInViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        flowController?.present(viewController, animated: true)
    }

    public func didTapSelfIsolationButton() {
        guard let viewController = flowInteractor.makeSelfIsolationHubViewController(
            flowController: flowController,
            showOrderTestButton: showOrderTestButton,
            showFinancialSupportButton: showFinancialSupportButton,
            showWarnAndBookATestFlow: showWarnAndBookATestFlow,
            recordSelectedIsolationPaymentsButton: recordSelectedIsolationPaymentsButton
        ) else {
            return
        }
        flowController?.pushViewController(viewController, animated: true)
    }

    public func didTapGuidanceHubEnglandButton() {
        guard let viewController = flowInteractor.makeGuidanceHubEnglandViewController(flowController: flowController) else {
            return
        }
        flowController?.pushViewController(viewController, animated: true)
    }

    public func didTapGuidanceHubWalesButton() {
        guard let viewController = flowInteractor.makeGuidanceHubWalesViewController(flowController: flowController) else {
            return
        }
        flowController?.pushViewController(viewController, animated: true)
    }

    public func didTapAboutButton() {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        let version = "\(appVersion) (\(buildNumber))"

        let viewController = AboutThisAppViewController(interactor: aboutThisAppInteractor, appName: appName, version: version)
        flowController?.pushViewController(viewController, animated: true)
    }

    func didTapSettingsButton() {
        let viewController = SettingsViewController(viewModel: SettingsViewController.ViewModel(), interacting: settingsInteractor)
        flowController?.pushViewController(viewController, animated: true)
    }

    public func didTapLinkTestResultButton() {
        guard let viewController = flowInteractor.makeLinkTestResultViewController() else {
            return
        }

        flowController?.present(viewController, animated: true)
    }

    public func didTapContactTracingHubButton() {

        let vc = WrappingViewController {
            bluetoothOff
                .regulate(as: .modelChange)
                .map { bluetoothOff in
                    if bluetoothOff {
                        return flowInteractor.makeBluetoothDisabledWarningViewController(flowController: flowController)
                    } else {
                        return flowInteractor.makeContactTracingHubViewController(
                            flowController: flowController,
                            exposureNotificationsEnabled: exposureNotificationsEnabled,
                            exposureNotificationsToggleAction: exposureNotificationsToggleAction,
                            userNotificationsEnabled: userNotificationsEnabled
                        )
                    }
                }
        }
        flowController?.pushViewController(vc, animated: true)
    }

    public func didTapTestingHubButton() {
        let testingHubViewController = flowInteractor.makeTestingHubViewController(
            flowController: flowController,
            showOrderTestButton: showOrderTestButton,
            showFindOutAboutTestingButton: showFindOutAboutTestingButton,
            showWarnAndBookATestFlow: showWarnAndBookATestFlow
        )
        flowController?.pushViewController(testingHubViewController, animated: true)
    }

    public var shouldShowCheckIn: Bool {
        flowInteractor.shouldShowCheckIn
    }

    public var shouldShowTestingForCOVID19: Bool {
        flowInteractor.shouldShowTestingForCOVID19
    }

    public var shouldShowSelfIsolation: Bool {
        flowInteractor.shouldShowSelfIsolation
    }

    public var shouldShowGuidanceHub: Bool {
        flowInteractor.shouldShowGuidanceHub
    }

    public var newLabelForLongCovidCurrentCountryState: NewLabelState {
        flowInteractor.newLabelForLongCovidCurrentCountryState
    }

    func openSettings() {
        flowInteractor.openSettings()
    }

    func didTapStatsButton() {
        let localStatsFlowContorller = flowInteractor.makeLocalCovidStatsViewController(flowController: flowController)
        flowController?.pushViewController(localStatsFlowContorller, animated: true)
    }

}

private struct AboutThisAppInteractor: AboutThisAppViewController.Interacting {
    func didTapProvideFeedback() {
        interactor.openProvideFeedbackLink()
    }

    private let interactor: HomeFlowViewController.Interacting
    private weak var flowController: HomeFlowViewController?

    init(flowController: HomeFlowViewController, interactor: HomeFlowViewController.Interacting) {
        self.flowController = flowController
        self.interactor = interactor
    }

    public func didTapHowThisAppWorks() {
        interactor.openHowThisAppWorksLink()
    }

    public func didTapCommonQuestions() {
        interactor.openFAQ()
    }

    public func didTapTermsOfUse() {
        interactor.openTearmsOfUseLink()
    }

    public func didTapPrivacyNotice() {
        interactor.openPrivacyLink()
    }

    public func didTapAccessibilityStatement() {
        interactor.openAccessibilityStatementLink()
    }

    public func didTapSeeData() {
        let viewController = MyDataViewController(viewModel: interactor.getMyDataViewModel())
        flowController?.pushViewController(viewController, animated: true)
    }

    public func didTapDownloadNHSApp() {
        interactor.openDownloadNHSAppLink()
    }
}

private struct RiskLevelInfoInteractor: RiskLevelInfoViewController.Interacting {
    private var interactor: HomeFlowViewController.Interacting

    init(interactor: HomeFlowViewController.Interacting) {
        self.interactor = interactor
    }

    public func didTapWebsiteLink(url: URL) {
        interactor.openWebsiteLinkfromRisklevelInfoScreen(url: url)
    }
}

private struct LocalInformationInteractor: LocalInformationViewController.Interacting {
    private let flowInteractor: HomeFlowViewController.Interacting
    private weak var flowController: UIViewController?

    init(flowController: UIViewController, flowInteractor: HomeFlowViewController.Interacting) {
        self.flowController = flowController
        self.flowInteractor = flowInteractor
    }

    func didTapExternalLink(url: URL) {
        flowInteractor.openWebsiteLinkfromLocalInfoScreen(url: url)
    }

    func didTapPrimaryButton() {
        flowController?.presentedViewController?.dismiss(animated: true)
    }

    func didTapCancel() {
        flowController?.presentedViewController?.dismiss(animated: true)
    }
}

private struct SettingsInteractor: SettingsViewController.Interacting {

    private weak var flowController: HomeFlowViewController?
    private var interactor: HomeFlowViewControllerInteracting

    var shouldShowVenueHistory: Bool

    init(flowController: HomeFlowViewController, interactor: HomeFlowViewControllerInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        self.shouldShowVenueHistory = interactor.shouldShowCheckIn
    }

    func didTapLanguage() {
        guard let viewController = makeLanguageSelectionViewController() else { return }
        flowController?.pushViewController(viewController, animated: true)
    }

    func didTapManageMyData() {
        let manageMyDataVC = makeManageMyDataViewController()
        flowController?.pushViewController(manageMyDataVC, animated: true)
    }

    private func makeMyAreaViewController() -> UIViewController? {
        let interactor = MyAreaTableViewControllerInteractor(flowController: flowController, interactor: self.interactor)
        return MyAreaTableViewController(viewModel: self.interactor.getMyAreaViewModel(), interactor: interactor)
    }

    func didTapDeleteAppData() {
        interactor.deleteAppData()
    }

    func didTapVenueHistory() {
        let venueHistoryVC = VenueHistoryViewController(
            viewModel: interactor.getVenueHistoryViewModel(),
            interactor: VenueHistoryViewControllerInteractor(homeFlowInteractor: interactor)
        )
        flowController?.pushViewController(venueHistoryVC, animated: true)
    }

    func didTapAnimations() {
        let vc = HomeAnimationsViewController(viewModel: interactor.getHomeAnimationsViewModel())
        flowController?.pushViewController(vc, animated: true)
    }

    func didTapMyArea() {
        guard let viewController = makeMyAreaViewController() else { return }
        flowController?.pushViewController(viewController, animated: true)
    }

    func makeLanguageSelectionViewController() -> UIViewController? {
        let interactor = LanguageSelectionViewControllerInteractor(_didSelectLanguage: { localeConfiguration in
            self.interactor.storeNewLanguage(localeConfiguration)
        })
        let systemLanguage = systemPreferredLanguageCode()
        let selectedLanguage = self.interactor.getCurrentLocaleConfiguration().wrappedValue
        guard let defaultLanguageTerms = SupportedLanguage.getLanguageTermsFrom(localeIdentifier: systemLanguage) else {
            return nil
        }
        let viewController = LanguageSelectionViewController(
            viewModel: .init(
                currentSelection: selectedLanguage,
                selectableDefault: SelectableLanguage(isoCode: systemLanguage, exonym: defaultLanguageTerms.exonym, endonym: defaultLanguageTerms.endonym),
                selectableOverrides: SupportedLanguage.allLanguages(
                    currentLocaleIdentifier: currentLocaleIdentifier(
                        localeConfiguration: selectedLanguage
                    )
                ).compactMap { $0 }
            ),
            interacting: interactor
        )
        return viewController
    }

    func makeManageMyDataViewController() -> UIViewController {
        return MyDataViewController(viewModel: interactor.getMyDataViewModel())
    }
}

struct LanguageSelectionViewControllerInteractor: LanguageSelectionViewController.Interacting {
    public var _didSelectLanguage: (LocaleConfiguration) -> Void

    public func didSelect(configuration: LocaleConfiguration) {
        _didSelectLanguage(configuration)
    }
}

struct MyAreaTableViewControllerInteractor: MyAreaTableViewController.Interacting {
    var _didTapEditPostcode: () -> Void

    internal init(flowController: HomeFlowViewController?, interactor: HomeFlowViewController.Interacting) {
        _didTapEditPostcode = { [weak flowController] in

            let localAuthorityFlowVC = LocalAuthorityFlowViewController(
                interactor.makeLocalAuthorityOnboardingInteractor(),
                isEditMode: true
            )
            localAuthorityFlowVC.modalPresentationStyle = .fullScreen
            flowController?.present(localAuthorityFlowVC, animated: true)
        }
    }

    func didTapEditPostcode() {
        _didTapEditPostcode()
    }

}

struct VenueHistoryViewControllerInteractor: VenueHistoryViewController.Interacting {
    var updateVenueHistories: (VenueHistory) -> [VenueHistory]

    init(homeFlowInteractor: HomeFlowViewController.Interacting) {
        updateVenueHistories = homeFlowInteractor.updateVenueHistories
    }
}
