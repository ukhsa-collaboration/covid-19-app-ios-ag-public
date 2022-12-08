//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingShareTestResultScreenScenario: Scenario {
    public static let name = "Self-Reporting - Share positive result"
    public static let kind = ScenarioKind.screen
    public static let primaryButtonTapped = "Continue button tapped"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingShareTestResultViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: SelfReportingShareTestResultViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton() {
        viewController.showAlert(title: SelfReportingShareTestResultScreenScenario.primaryButtonTapped)
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingShareTestResultScreenScenario.backButtonTapped)
    }
}
