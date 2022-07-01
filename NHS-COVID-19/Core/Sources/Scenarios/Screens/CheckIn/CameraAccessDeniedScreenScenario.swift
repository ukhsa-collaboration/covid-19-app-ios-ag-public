//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class CameraAccessDeniedScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Camera Access Denied"

    public static let openSettingsTapped = "Enable camera access tapped!"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return CameraAccessDeniedViewController(interactor: interactor)
        }
    }
}

private class Interactor: CameraAccessDeniedViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func openSettings() {
        viewController?.showAlert(title: CameraAccessDeniedScreenScenario.openSettingsTapped)
    }

}
