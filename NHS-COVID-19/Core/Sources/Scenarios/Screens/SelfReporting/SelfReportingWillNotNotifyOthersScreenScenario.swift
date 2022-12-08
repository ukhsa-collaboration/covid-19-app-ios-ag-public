//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingWillNotNotifyOthersScreenScenario: Scenario {
    public static let name = "Self-Reporting - App will not notify others"
    public static let kind = ScenarioKind.screen
    public static let primaryButtonTapped = "Continue button tapped"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingWillNotNotifyOthersViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: SelfReportingWillNotNotifyOthersViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton() {
        viewController.showAlert(title: SelfReportingWillNotNotifyOthersScreenScenario.primaryButtonTapped)
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingWillNotNotifyOthersScreenScenario.backButtonTapped)
    }
}
