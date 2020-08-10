//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

internal protocol HomeScreenScenario: Scenario {
    static var riskyPostcodeEnabled: Bool { get }
    static var checkInEnabled: Bool { get }
    static var showOrderTestButton: Bool { get }
    static var shouldShowSelfDiagnosis: Bool { get }
}

extension HomeScreenScenario {
    
    static func postcodeViewModel(parent: UIViewController) -> RiskLevelBanner.ViewModel? {
        if Self.riskyPostcodeEnabled {
            return RiskLevelBanner.ViewModel(postcode: "SW12", riskLevel: .constant(.low)) {
                parent.showAlert(title: HomeScreenAlerts.moreInfoAlertTitle)
            }
        } else {
            return nil
        }
    }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            
            let exposureNotificationsEnabled = CurrentValueSubject<Bool, Never>(true)
            
            return HomeViewController(
                interactor: Interactor(
                    viewController: parent,
                    checkInEnabled: checkInEnabled,
                    setExposureNotifcationEnabled: { enabled in
                        exposureNotificationsEnabled.send(enabled)
                    }
                ),
                postcodeRiskViewModel: postcodeViewModel(parent: parent),
                isolationViewModel: RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(false)),
                exposureNotificationsEnabled: exposureNotificationsEnabled.eraseToAnyPublisher(),
                showOrderTestButton: .constant(showOrderTestButton),
                shouldShowSelfDiagnosis: .constant(shouldShowSelfDiagnosis)
            )
        }
    }
}

public class SuccessHomeScreenScenario: HomeScreenScenario {
    public static var name = "Home Screen"
    
    public static var kind = ScenarioKind.screen
    
    public static var riskyPostcodeEnabled = true
    public static var selfDiagnosisEnabled: Bool = true
    public static var checkInEnabled: Bool = true
    public static var showOrderTestButton = true
    public static var shouldShowSelfDiagnosis = true
}

public class DisabledFeaturesHomeScreenScenario: HomeScreenScenario {
    public static var name = "Features disabled Homescreen"
    
    public static var kind = ScenarioKind.prototype
    
    public static var riskyPostcodeEnabled = false
    public static var selfDiagnosisEnabled = false
    public static var checkInEnabled: Bool = false
    public static var showOrderTestButton = false
    public static var shouldShowSelfDiagnosis = false
}

public class HomeScreenAlerts {
    public static let diagnosisAlertTitle = "I don't feel well button tapped."
    public static let adviceAlertTitle = "Read current advice button tapped."
    public static let isolationAdviceAlertTitle = "Read isolation advice button tapped."
    public static let checkInAlertTitle = "Check-in into a venue."
    public static let testingInformationAlertTitle = "Testing information button tapped"
    public static let exposureNotificationAlertTitle = "Exposure notificiatons toggled"
    public static let aboutAlertTitle = "About tapped"
    public static let moreInfoAlertTitle = "More info tapped"
    public static let contactTracingAlertTitle = "Contact tracing tapped"
}

private class Interactor: HomeViewController.Interacting {
    
    var checkInEnabled: Bool
    var _setExposureNotifcationEnabled: (Bool) -> Void
    
    private weak var viewController: UIViewController?
    
    init(
        viewController: UIViewController,
        checkInEnabled: Bool,
        setExposureNotifcationEnabled: @escaping (Bool) -> Void
    ) {
        self.viewController = viewController
        self.checkInEnabled = checkInEnabled
        _setExposureNotifcationEnabled = setExposureNotifcationEnabled
    }
    
    func didTapDiagnosisButton() {
        viewController?.showAlert(title: HomeScreenAlerts.diagnosisAlertTitle)
    }
    
    func didTapAdviceButton() {
        viewController?.showAlert(title: HomeScreenAlerts.adviceAlertTitle)
    }
    
    func didTapIsolationAdviceButton() {
        viewController?.showAlert(title: HomeScreenAlerts.isolationAdviceAlertTitle)
    }
    
    func didTapCheckInButton() {
        viewController?.showAlert(title: HomeScreenAlerts.checkInAlertTitle)
    }
    
    func didTapTestingInformationButton() {
        viewController?.showAlert(title: HomeScreenAlerts.testingInformationAlertTitle)
    }
    
    func didTapAboutButton() {
        viewController?.showAlert(title: HomeScreenAlerts.aboutAlertTitle)
    }
    
    func didtapContactTracingButton() {
        viewController?.showAlert(title: HomeScreenAlerts.contactTracingAlertTitle)
    }
    
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        viewController?.showAlert(title: HomeScreenAlerts.exposureNotificationAlertTitle)
        _setExposureNotifcationEnabled(enabled)
        return Result.success(()).publisher.eraseToAnyPublisher()
    }
    
    var shouldShowCheckIn: Bool {
        checkInEnabled
    }
}
