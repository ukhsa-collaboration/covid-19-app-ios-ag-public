//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class AuthorizationDeniedScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Onboarding - Exposure Logging denied"

    public static let openSettingsTapped = "Go to settings tapped!"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return AuthorizationDeniedViewController(interacting: interactor, country: .england)
        }
    }
}

private class Interactor: AuthorizationDeniedViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapSettings() {
        viewController?.showAlert(title: AuthorizationDeniedScreenScenario.openSettingsTapped)
    }

}
