//
// Copyright © 2022 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class GuidanceForSymptomaticCasesEnglandViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Guidance screen for symptomatic cases in Enland"

    public static let commonQuestionsLinkTapped: String = "Common questions link tapped"
    public static let nhsOnlineLinkTapped: String = "NHS online link tapped"
    public static let backToHomeTapped = "Back to home button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return GuidanceForSymptomaticCasesEnglandViewController(interactor: interactor)
        }
    }
}

private class Interactor: GuidanceForSymptomaticCasesEnglandViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: GuidanceForSymptomaticCasesEnglandViewControllerScenario.commonQuestionsLinkTapped)
    }

    func didTapNHSOnlineLink() {
        viewController?.showAlert(title: GuidanceForSymptomaticCasesEnglandViewControllerScenario.nhsOnlineLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: GuidanceForSymptomaticCasesEnglandViewControllerScenario.backToHomeTapped)
    }

}
