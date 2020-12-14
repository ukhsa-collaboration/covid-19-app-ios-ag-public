//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class FinanacialSupportScreenScenario: Scenario {
    
    public static let name = "Financial support"
    public static let kind = ScenarioKind.screen
    public static let financialHelpEnglandLinkAlertTitle = "Visit financial help for England is tapped"
    public static let financialHelpWalesLinkAlertTitle = "Visit financial help for Wales is tapped"
    public static let checkYourEligibilityAlertTitle = "Check your eligibility button tapped"
    public static let privacyNoticeAlertTitle = "Privacy notice button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return FinancialSupportViewController(interactor: interactor)
        }
    }
}

private class Interactor: FinancialSupportViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapHelpForEngland() {
        viewController?.showAlert(title: FinanacialSupportScreenScenario.financialHelpEnglandLinkAlertTitle)
    }
    
    func didTapHelpForWales() {
        viewController?.showAlert(title: FinanacialSupportScreenScenario.financialHelpWalesLinkAlertTitle)
    }
    
    func didTapCheckEligibility() {
        viewController?.showAlert(title: FinanacialSupportScreenScenario.checkYourEligibilityAlertTitle)
    }
    
    func didTapViewPrivacyNotice() {
        viewController?.showAlert(title: FinanacialSupportScreenScenario.privacyNoticeAlertTitle)
    }
}
