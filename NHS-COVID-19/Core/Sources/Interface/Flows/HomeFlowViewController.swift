//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public protocol HomeFlowViewControllerInteracting: MyDataViewControllerInteracting {
    var riskLevelInfoViewModel: RiskLevelInfoViewModel? { get }
    func makeDiagnosisViewController() -> UIViewController?
    func openAdvice()
    func openIsolationAdvice()
    func makeCheckInViewController() -> UIViewController?
    func makeTestingInformationViewController() -> UIViewController?
    func getAppData() -> AppData
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    var shouldShowCheckIn: Bool { get }
    func openTearmsOfUseLink()
    func openPrivacyLink()
    func openFAQ()
    func openAccessibilityStatementLink()
    func openHowThisAppWorksLink()
    func openWebsiteLinkfromRisklevelInfoScreen()
}

public class HomeFlowViewController: UINavigationController {
    
    public typealias Interacting = HomeFlowViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(
        interactor: Interacting,
        postcodeViewModel: RiskLevelBanner.ViewModel?,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        let rootViewController = HomeViewController(
            interactor: self,
            postcodeRiskViewModel: postcodeViewModel,
            isolationViewModel: isolationViewModel,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis
        )
        viewControllers = [rootViewController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeFlowViewController: HomeViewController.Interacting {
    
    public func didTapMoreInfo() {
        guard let vm = interactor.riskLevelInfoViewModel else { return }
        let viewController = RiskLevelInfoViewController(viewModel: vm, interactor: self)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overFullScreen
        
        present(navigationController, animated: true)
    }
    
    public func didTapAdviceButton() {
        interactor.openAdvice()
    }
    
    public func didTapIsolationAdviceButton() {
        interactor.openIsolationAdvice()
    }
    
    public func didTapDiagnosisButton() {
        guard let viewController = interactor.makeDiagnosisViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
    public func didTapCheckInButton() {
        guard let viewController = interactor.makeCheckInViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
    public func didTapTestingInformationButton() {
        guard let viewController = interactor.makeTestingInformationViewController() else {
            return
        }
        viewController.modalPresentationStyle = .overFullScreen
        present(viewController, animated: true)
    }
    
    public func didTapAboutButton() {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
        let version = "\(appVersion) (\(buildNumber))"
        
        let viewController = AboutThisAppViewController(interactor: self, appName: appName, version: version)
        viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
        pushViewController(viewController, animated: true)
    }
    
    public func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        interactor.setExposureNotifcationEnabled(enabled)
    }
    
    public var shouldShowCheckIn: Bool {
        interactor.shouldShowCheckIn
    }
}

extension HomeFlowViewController: AboutThisAppViewController.Interacting {
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
        let data = interactor.getAppData()
        let viewController = UIHostingController(rootView: MyDataView(interactor: interactor, data: data))
        viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
        pushViewController(viewController, animated: true)
    }
    
}

extension HomeFlowViewController: RiskLevelInfoViewController.Interacting {
    
    public func didTapWebsiteLink() {
        interactor.openWebsiteLinkfromRisklevelInfoScreen()
    }
}
