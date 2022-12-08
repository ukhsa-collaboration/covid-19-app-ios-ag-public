//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingResultReportedScreenScenario: Scenario {
    public static let name = "Self-Reporting - Whether you've reported your result"
    public static let kind = ScenarioKind.screen
    public static let yesSelected = "Yes selected"
    public static let noSelected = "No selected"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingQuestionViewController(
                interactor: Interactor(viewController: parent),
                firstChoice: nil,
                state: .reportedResult(symptoms: false)
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
            ? SelfReportingResultReportedScreenScenario.yesSelected
            : SelfReportingResultReportedScreenScenario.noSelected
        )
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingResultReportedScreenScenario.backButtonTapped)
    }
}
