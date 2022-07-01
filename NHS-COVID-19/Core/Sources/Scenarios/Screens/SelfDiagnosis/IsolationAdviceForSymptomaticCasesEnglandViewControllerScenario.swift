//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class IsolationAdviceForSymptomaticCasesEnglandViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Isolation Advice for Symptomatic cases England"

    public static let continueButtonTapped = "Continue button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = IsolationAdviceForSymptomaticCasesEnglandInteractor(viewController: parent)
            return IsolationAdviceForSymptomaticCasesEnglandViewController(interactor: interactor)
        }
    }
}

private class IsolationAdviceForSymptomaticCasesEnglandInteractor: IsolationAdviceForSymptomaticCasesEnglandViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapContinue() {
        viewController?.showAlert(title: IsolationAdviceForSymptomaticCasesEnglandViewControllerScenario.continueButtonTapped)
    }

}
