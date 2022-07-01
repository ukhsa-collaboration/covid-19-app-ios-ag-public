//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class PolicyUpdateScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Policy Update"

    public static let continueTapped = "Continue tapped!"
    public static let termsOfUseTapped = "Terms of Use tapped!"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PolicyUpdateViewController(interactor: interactor)
        }
    }
}

private class Interactor: PolicyUpdateViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapContinue() {
        viewController?.showAlert(title: PolicyUpdateScreenScenario.continueTapped)
    }

    func didTapTermsOfUse() {
        viewController?.showAlert(title: PolicyUpdateScreenScenario.termsOfUseTapped)
    }
}
