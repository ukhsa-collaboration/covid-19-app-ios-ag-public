//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public protocol HomeFlowViewControllerInteracting {
    func makeDiagnosisViewController() -> UIViewController?
    func openAdvice()
    func openIsolationAdvice()
    func makeCheckInViewController() -> UIViewController?
    func makeTestingInformationViewController() -> UIViewController?
    func makeFinancialSupportViewController() -> UIViewController?
    func makeLinkTestResultViewController() -> UIViewController?
    func makeDailyConfirmationViewController(parentVC: UIViewController, with terminate: @escaping () -> Void) -> UIViewController?
    func getMyDataViewModel() -> MyDataViewController.ViewModel
    func getMyAreaViewModel() -> MyAreaTableViewController.ViewModel
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn)
    var shouldShowCheckIn: Bool { get }
    func openTearmsOfUseLink()
    func openPrivacyLink()
    func openFAQ()
    func openAccessibilityStatementLink()
    func openHowThisAppWorksLink()
    func openWebsiteLinkfromRisklevelInfoScreen(url: URL)
    func openProvideFeedbackLink()
    func deleteAppData()
    func updateVenueHistories(deleting venueHistory: VenueHistory) -> [VenueHistory]
    func makeLocalAuthorityOnboardingInteractor() -> LocalAuthorityFlowViewController.Interacting
    func getCurrentLocaleConfiguration() -> InterfaceProperty<LocaleConfiguration>
    func storeNewLanguage(_ localeConfiguration: LocaleConfiguration) -> Void
    func getVenueHistoryViewModel() -> VenueHistoryViewController.ViewModel
}

public enum ExposureNotificationReminderIn: Int, CaseIterable {
    case fourHours = 4
    case eightHours = 8
    case twelveHours = 12
}

public class HomeFlowViewController: BaseNavigationController {
    
    public typealias Interacting = HomeFlowViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(
        interactor: Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>,
        recordSelectedIsolationPaymentsButton: @escaping () -> Void,
        country: InterfaceProperty<Country>,
        shouldShowLanguageSelectionScreen: Bool
    ) {
        self.interactor = interactor
        super.init()
        
        let aboutThisAppInteractor = AboutThisAppInteractor(flowController: self, interactor: interactor)
        let settingsInteractor = SettingsInteractor(flowController: self, interactor: interactor)
        let riskLevelInteractor = RiskLevelInfoInteractor(interactor: interactor)
        let homeViewControllerInteractor = HomeViewControllerInteractor(
            flowController: self,
            flowInteractor: interactor,
            riskLevelInteractor: riskLevelInteractor,
            aboutThisAppInteractor: aboutThisAppInteractor,
            settingsInteractor: settingsInteractor,
            recordSelectedIsolationPaymentsButton: recordSelectedIsolationPaymentsButton
        )
        
        let showLanguageSelectionScreen: () -> Void = {
            let viewController = SettingsViewController(viewModel: SettingsViewController.ViewModel(), interacting: settingsInteractor)
            self.pushViewController(viewController, animated: false)
            if let languageViewController = settingsInteractor.makeLanguageSelectionViewController() {
                self.pushViewController(languageViewController, animated: false)
            }
        }
        
        let rootViewController = HomeViewController(
            interactor: homeViewControllerInteractor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationsEnabled,
            showFinancialSupportButton: showFinancialSupportButton,
            country: country,
            showLanguageSelectionScreen: shouldShowLanguageSelectionScreen ? showLanguageSelectionScreen : nil
        )
        
        viewControllers = [rootViewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct HomeViewControllerInteractor: HomeViewController.Interacting {
    private weak var flowController: UINavigationController?
    private let flowInteractor: HomeFlowViewController.Interacting
    private let riskLevelInteractor: RiskLevelInfoViewController.Interacting
    private let aboutThisAppInteractor: AboutThisAppViewController.Interacting
    private let settingsInteractor: SettingsViewController.Interacting
    private let recordSelectedIsolationPaymentsButton: () -> Void
    
    init(
        flowController: UINavigationController,
        flowInteractor: HomeFlowViewController.Interacting,
        riskLevelInteractor: RiskLevelInfoViewController.Interacting,
        aboutThisAppInteractor: AboutThisAppViewController.Interacting,
        settingsInteractor: SettingsViewController.Interacting,
        recordSelectedIsolationPaymentsButton: @escaping () -> Void
    ) {
        self.flowController = flowController
        self.flowInteractor = flowInteractor
        self.riskLevelInteractor = riskLevelInteractor
        self.aboutThisAppInteractor = aboutThisAppInteractor
        self.settingsInteractor = settingsInteractor
        self.recordSelectedIsolationPaymentsButton = recordSelectedIsolationPaymentsButton
    }
    
    public func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel) {
        let viewController = RiskLevelInfoViewController(viewModel: viewModel, interactor: riskLevelInteractor)
        let navigationController = BaseNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        
        flowController?.present(navigationController, animated: true)
    }
    
    public func didTapAdviceButton() {
        flowInteractor.openAdvice()
    }
    
    public func didTapIsolationAdviceButton() {
        flowInteractor.openIsolationAdvice()
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
    
    public func didTapTestingInformationButton() {
        guard let viewController = flowInteractor.makeTestingInformationViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        flowController?.present(viewController, animated: true)
    }
    
    public func didTapFinancialSupportButton() {
        guard let viewController = flowInteractor.makeFinancialSupportViewController() else {
            return
        }
        recordSelectedIsolationPaymentsButton()
        viewController.modalPresentationStyle = .overFullScreen
        flowController?.present(viewController, animated: true)
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
    
    public func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        flowInteractor.setExposureNotifcationEnabled(enabled)
    }
    
    public func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        flowInteractor.scheduleReminderNotification(reminderIn: reminderIn)
    }
    
    public var shouldShowCheckIn: Bool {
        flowInteractor.shouldShowCheckIn
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
}

private struct RiskLevelInfoInteractor: RiskLevelInfoViewController.Interacting {
    private var interactor: HomeFlowViewController.Interacting
    
    init(interactor: HomeFlowViewController.Interacting) {
        self.interactor = interactor
    }
    
    public func didTapWebsiteLink(url: URL) {
        interactor.openWebsiteLinkfromRisklevelInfoScreen(url: url)
    }
    
    public func didTapFindTestCenterLink(url: URL) {
        interactor.openWebsiteLinkfromRisklevelInfoScreen(url: url)
    }
}

private struct SettingsInteractor: SettingsViewController.Interacting {
    func didTapMyArea() {
        guard let viewController = makeMyAreaViewController() else { return }
        flowController?.pushViewController(viewController, animated: true)
    }
    
    private weak var flowController: HomeFlowViewController?
    private var interactor: HomeFlowViewControllerInteracting
    
    init(flowController: HomeFlowViewController, interactor: HomeFlowViewControllerInteracting) {
        self.flowController = flowController
        self.interactor = interactor
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
