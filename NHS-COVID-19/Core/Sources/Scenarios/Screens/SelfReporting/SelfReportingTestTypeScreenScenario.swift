//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingTestTypeScreenScenario: Scenario {
    public static let name = "Self-Reporting Hub"
    public static let kind = ScenarioKind.screen
    public static let positiveTestSelected = "Positive test selected"
    public static let negativeTestSelected = "Negative test selected"
    public static let voidTestSelected = "Void test selected"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingTestTypeViewController(
                interactor: Interactor(viewController: parent),
                testResult: nil
            )
        }
    }
}

private struct Interactor: SelfReportingTestTypeViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton(_ testResult: TestResult) {
        var title = ""
        switch testResult {
        case .positive:
            title = SelfReportingTestTypeScreenScenario.positiveTestSelected
        case .negative:
            title = SelfReportingTestTypeScreenScenario.negativeTestSelected
        case .void:
            title = SelfReportingTestTypeScreenScenario.voidTestSelected
        }
        viewController.showAlert(title: title)
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingTestTypeScreenScenario.backButtonTapped)
    }
}
