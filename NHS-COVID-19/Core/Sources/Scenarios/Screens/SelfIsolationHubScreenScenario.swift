//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfIsolationHubScreenScenario: Scenario {
    public static let name = "Self-Isolation Hub"
    public static let kind = ScenarioKind.screen
    public static let bookATestAlertTitle = "Book a test button tapped"
    public static let financialSupportAlertTitle = "Financial support button tapped"
    public static let readGovernmentGuidanceAlertTitle = "Read government guidance link tapped"
    public static let findYourLocalAuthorityAlertTitle = "Find your local authority link tapped"
    public static let getIsolationNoteAlertTitle = "Get Isolation note link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in

            SelfIsolationHubViewController(
                interactor: Interactor(viewController: parent),
                showOrderTestButton: .constant(true),
                showFinancialSupportButton: .constant(true)
            )
        }
    }
}

private struct Interactor: SelfIsolationHubViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapBookFreeTestButton() {
        viewController.showAlert(title: SelfIsolationHubScreenScenario.bookATestAlertTitle)
    }

    func didTapCheckIfEligibleForFinancialSupport() {
        viewController.showAlert(title: SelfIsolationHubScreenScenario.financialSupportAlertTitle)
    }

    func didTapReadGovernmentGuidanceLink() {
        viewController.showAlert(title: SelfIsolationHubScreenScenario.readGovernmentGuidanceAlertTitle)
    }

    func didTapFindYourLocalAuthorityLink() {
        viewController.showAlert(title: SelfIsolationHubScreenScenario.findYourLocalAuthorityAlertTitle)
    }

    func didTapGetIsolationNoteLink() {
        viewController.showAlert(title: SelfIsolationHubScreenScenario.getIsolationNoteAlertTitle)
    }
}
