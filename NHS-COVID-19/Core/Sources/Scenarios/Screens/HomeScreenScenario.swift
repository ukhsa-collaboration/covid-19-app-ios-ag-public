//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import Localization
import UIKit

internal protocol HomeScreenScenario: Scenario {
    static var riskyPostcodeEnabled: Bool { get }
    static var checkInEnabled: Bool { get }
    static var testingForCOVID19Enabled: Bool { get }
    static var selfIsolationEnabled: Bool { get }
    static var guidanceHubEnabled: Bool { get }
    static var shouldShowSelfDiagnosis: Bool { get }
    static var localInformationEnabled: Bool { get }
}

extension HomeScreenScenario {
    
    static func postcodeViewModel(parent: UIViewController) -> RiskLevelBanner.ViewModel? {
        if Self.riskyPostcodeEnabled {
            return RiskLevelBanner.ViewModel(
                postcode: "SW12",
                colorScheme: .green,
                title: "SW12 is in Local Alert Level 1".apply(direction: currentLanguageDirection()),
                infoTitle: "SW12 is in Local Alert Level 1",
                heading: [],
                body: [],
                linkTitle: "Restrictions in your area",
                linkURL: nil,
                footer: [],
                policies: []
            )
        } else {
            return nil
        }
    }
    
    static var localInfoBannerViewModel: LocalInformationBanner.ViewModel? {
        if Self.localInformationEnabled {
            return .init(text: "A new variant of concern is in your area.", localInfoScreenViewModel: .init(header: "", body: []))
        }
        return nil
    }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            
            let exposureNotificationsEnabled = CurrentValueSubject<Bool, Never>(true)
            
            return HomeViewController(
                interactor: Interactor(
                    viewController: parent,
                    checkInEnabled: checkInEnabled,
                    testingForCOVID19Enabled: testingForCOVID19Enabled,
                    selfIsolationEnabled: selfIsolationEnabled,
                    guidanceHubEnabled: guidanceHubEnabled
                ),
                riskLevelBannerViewModel: .constant(postcodeViewModel(parent: parent)),
                localInfoBannerViewModel: .constant(localInfoBannerViewModel),
                isolationViewModel: RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(false), animationDisabled: .constant(false), bluetoothOff: .constant(false), country: .constant(.england)),
                exposureNotificationsEnabled: exposureNotificationsEnabled.property(initialValue: false),
                exposureNotificationsToggleAction: { [weak parent] toggle in
                    parent?.showAlert(title: "Toggle state changed to \(toggle)")
                },
                shouldShowSelfDiagnosis: .constant(shouldShowSelfDiagnosis),
                userNotificationsEnabled: .constant(false),
                showFinancialSupportButton: .constant(true),
                country: .constant(.england),
                showLanguageSelectionScreen: nil,
                shouldShowLocalStats: true
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
    public static var testingForCOVID19Enabled: Bool = true
    public static var selfIsolationEnabled: Bool = true
    public static var shouldShowSelfDiagnosis = true
    public static var localInformationEnabled = true
    public static var guidanceHubEnabled = true
}

public class DisabledFeaturesHomeScreenScenario: HomeScreenScenario {
    public static var name = "Home Screen – All Features disabled"
    
    public static var kind = ScenarioKind.screen
    
    public static var riskyPostcodeEnabled = false
    public static var selfDiagnosisEnabled = false
    public static var checkInEnabled: Bool = false
    public static var testingForCOVID19Enabled: Bool = false
    public static var selfIsolationEnabled: Bool = false
    public static var shouldShowSelfDiagnosis = false
    public static var localInformationEnabled = false
    public static var guidanceHubEnabled = false
}

public class HomeScreenAlerts {
    public static let diagnosisAlertTitle = "I don't feel well button tapped."
    public static let checkInAlertTitle = "Check-in into a venue."
    public static let settingsAlertTitle = "Settings button tapped"
    public static let aboutAlertTitle = "About tapped"
    public static let linkTestResultTitle = "Link test result tapped"
    public static let postcodeBannerAlertTitle = "Postcode banner tapped"
    public static let localInfoBannerAlertTitle = "Local Information banner tapped"
    public static let contactTracingHubAlertTitle = "Contact Tracing Hub tapped"
    public static let testingHubAlertTitle = "Testing Hub tapped"
    public static let selfIsolationAlertTitle = "Self-isolation button tapped"
    public static let openSettingAlertTitle = "Open phone settings button tapped"
    public static let statsTappedAlertTitle = "Stats button tapped"
    public static let openGuidanceHubEnglandAlertTitle = "Guidance Hub England button tapped"
    public static let openGuidanceHubWalesAlertTitle = "Guidance Hub Wales button tapped"
}

private class Interactor: HomeViewController.Interacting {
    
    var checkInEnabled: Bool
    var testingForCOVID19Enabled: Bool
    var selfIsolationEnabled: Bool
    var guidanceHubEnabled: Bool
    
    private weak var viewController: UIViewController?
    
    init(
        viewController: UIViewController,
        checkInEnabled: Bool,
        testingForCOVID19Enabled: Bool,
        selfIsolationEnabled: Bool,
        guidanceHubEnabled: Bool
    ) {
        self.viewController = viewController
        self.checkInEnabled = checkInEnabled
        self.testingForCOVID19Enabled = testingForCOVID19Enabled
        self.selfIsolationEnabled = selfIsolationEnabled
        self.guidanceHubEnabled = guidanceHubEnabled
    }
    
    func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel) {
        viewController?.showAlert(title: HomeScreenAlerts.postcodeBannerAlertTitle)
    }
    
    func didTapLocalInfoBanner(viewModel: LocalInformationViewController.ViewModel) {
        viewController?.showAlert(title: HomeScreenAlerts.localInfoBannerAlertTitle)
    }
    
    func didTapSelfIsolationButton() {
        viewController?.showAlert(title: HomeScreenAlerts.selfIsolationAlertTitle)
    }
    
    func didTapDiagnosisButton() {
        viewController?.showAlert(title: HomeScreenAlerts.diagnosisAlertTitle)
    }
    
    func didTapCheckInButton() {
        viewController?.showAlert(title: HomeScreenAlerts.checkInAlertTitle)
    }
    
    func didTapAboutButton() {
        viewController?.showAlert(title: HomeScreenAlerts.aboutAlertTitle)
    }
    
    func didTapSettingsButton() {
        viewController?.showAlert(title: HomeScreenAlerts.settingsAlertTitle)
    }
    
    func didTapLinkTestResultButton() {
        viewController?.showAlert(title: HomeScreenAlerts.linkTestResultTitle)
    }
    
    func didTapContactTracingHubButton() {
        viewController?.showAlert(title: HomeScreenAlerts.contactTracingHubAlertTitle)
    }
    
    func didTapTestingHubButton() {
        viewController?.showAlert(title: HomeScreenAlerts.testingHubAlertTitle)
    }
    
    var shouldShowCheckIn: Bool {
        checkInEnabled
    }
    
    var shouldShowTestingForCOVID19: Bool {
        testingForCOVID19Enabled
    }
    
    var shouldShowSelfIsolation: Bool {
        selfIsolationEnabled
    }
    
    var shouldShowGuidanceHub: Bool {
        guidanceHubEnabled
    }
    
    func openSettings() {
        viewController?.showAlert(title: HomeScreenAlerts.openSettingAlertTitle)
    }
    
    func didTapStatsButton() {
        viewController?.showAlert(title: HomeScreenAlerts.statsTappedAlertTitle)
    }
    
    func didTapGuidanceHubEnglandButton() {
        viewController?.showAlert(title: HomeScreenAlerts.openGuidanceHubEnglandAlertTitle)
    }
    
    func didTapGuidanceHubWalesButton() {
        viewController?.showAlert(title: HomeScreenAlerts.openGuidanceHubWalesAlertTitle)
    }

}
