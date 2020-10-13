//
// Copyright © 2020 NHSX. All rights reserved.
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
    func makeLinkTestResultViewController() -> UIViewController?
    func getMyDataViewModel() -> MyDataViewController.ViewModel
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
    func save(postcode: String) -> Result<Void, DisplayableError>
}

public enum ExposureNotificationReminderIn: Int, CaseIterable {
    case fourHours = 4
    case eightHours = 8
    case twelveHours = 12
}

public class HomeFlowViewController: UINavigationController {
    
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
        country: InterfaceProperty<Country>
    ) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        let aboutThisAppInteractor = AboutThisAppInteractor(flowController: self, interactor: interactor)
        let riskLevelInteractor = RiskLevelInfoInteractor(interactor: interactor)
        let homeViewControllerInteractor = HomeViewControllerInteractor(
            flowController: self,
            flowInteractor: interactor,
            riskLevelInteractor: riskLevelInteractor,
            aboutThisAppInteractor: aboutThisAppInteractor
        )
        
        let rootViewController = HomeViewController(
            interactor: homeViewControllerInteractor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            userNotificationsEnabled: userNotificationsEnabled,
            country: country
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
    
    init(
        flowController: UINavigationController,
        flowInteractor: HomeFlowViewController.Interacting,
        riskLevelInteractor: RiskLevelInfoViewController.Interacting,
        aboutThisAppInteractor: AboutThisAppViewController.Interacting
    ) {
        self.flowController = flowController
        self.flowInteractor = flowInteractor
        self.riskLevelInteractor = riskLevelInteractor
        self.aboutThisAppInteractor = aboutThisAppInteractor
    }
    
    public func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel) {
        let viewController = RiskLevelInfoViewController(viewModel: viewModel, interactor: riskLevelInteractor)
        let navigationController = UINavigationController(rootViewController: viewController)
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
    
    public func didTapAboutButton() {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        let version = "\(appVersion) (\(buildNumber))"
        
        let viewController = AboutThisAppViewController(interactor: aboutThisAppInteractor, appName: appName, version: version)
        flowController?.viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
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
        let interactor = MyDataViewInteractor(flowController: flowController, interactor: self.interactor)
        let viewController = MyDataViewController(viewModel: self.interactor.getMyDataViewModel(), interactor: interactor)
        flowController?.viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
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
}

private struct MyDataViewInteractor: MyDataViewController.Interacting {
    var deleteAppData: () -> Void
    var updateVenueHistories: (VenueHistory) -> [VenueHistory]
    var didTapEditPostcode: () -> Void
    
    init(flowController: HomeFlowViewController?, interactor: HomeFlowViewController.Interacting) {
        deleteAppData = interactor.deleteAppData
        updateVenueHistories = interactor.updateVenueHistories
        didTapEditPostcode = { [weak flowController] in
            let interactor = EditPostcodeInteractor(flowController: flowController, interactor: interactor)
            let viewController = EditPostcodeViewController(interactor: interactor)
            flowController?.pushViewController(viewController, animated: true)
        }
    }
}

private struct EditPostcodeInteractor: EditPostcodeViewController.Interacting {
    var savePostcode: (String) -> Result<Void, DisplayableError>
    var didTapCancel: () -> Void
    
    init(flowController: HomeFlowViewController?, interactor: HomeFlowViewController.Interacting) {
        savePostcode = { [weak flowController] postcode in
            let result = interactor.save(postcode: postcode)
            if case .success = result {
                flowController?.popViewController(animated: true)
            }
            return result
        }
        
        didTapCancel = {
            flowController?.popViewController(animated: true)
        }
    }
}
