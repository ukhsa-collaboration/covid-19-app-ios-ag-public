//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelfReportingTestKitTypeScreenScenario: Scenario {
    public static let name = "Self-Reporting Test Kit Type"
    public static let kind = ScenarioKind.screen
    public static let lfdTestSelected = "LFD test selected"
    public static let pcrTestSelected = "PCR test selected"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SelfReportingQuestionViewController(
                interactor: Interactor(viewController: parent), firstChoice: nil,
                state: .testKitType(keysShared: true)
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
            ? SelfReportingTestKitTypeScreenScenario.lfdTestSelected
            : SelfReportingTestKitTypeScreenScenario.pcrTestSelected
        )
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingTestKitTypeScreenScenario.backButtonTapped)
    }
}
