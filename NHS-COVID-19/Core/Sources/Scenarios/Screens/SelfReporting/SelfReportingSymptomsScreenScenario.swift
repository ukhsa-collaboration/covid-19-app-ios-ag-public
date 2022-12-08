//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingSymptomsScreenScenario: Scenario {
    public static let name = "Self-Reporting - Symptoms"
    public static let kind = ScenarioKind.screen
    public static let yesSelected = "Yes selected"
    public static let noSelected = "No selected"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingQuestionViewController(
                interactor: Interactor(viewController: parent),
                firstChoice: nil,
                state: .symptoms
            )
        }
    }
}

private struct Interactor: SelfReportingQuestionViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton(_ firstChoice: Bool) {
        viewController.showAlert(title: firstChoice
            ? SelfReportingTestSupplierScreenScenario.yesSelected
            : SelfReportingTestSupplierScreenScenario.noSelected
        )
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingTestSupplierScreenScenario.backButtonTapped)
    }
}
