//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import SwiftUI
import UIKit

public protocol HomeFlowViewControllerInteracting: MyDataViewControllerInteracting {
    func makeDiagnosisViewController() -> UIViewController?
    func openAdvice()
    func openIsolationAdvice()
    func makeCheckInViewController() -> UIViewController?
    func makeTestingInformationViewController() -> UIViewController?
    func getAppData() -> AppData
    func openAboutContactTracingLink()
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    var shouldShowCheckIn: Bool { get }
    func openTearmsOfUseLink()
    func openPrivacyLink()
    func openFAQ()
    func openAccessibilityStatementLink()
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
    
    public func didtapContactTracingButton() {
        interactor.openAboutContactTracingLink()
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
        pushViewController(viewController, animated: true)
    }
    
}
