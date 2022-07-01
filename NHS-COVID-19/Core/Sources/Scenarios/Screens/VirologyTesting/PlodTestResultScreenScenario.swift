//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class PlodTestResultScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - PLOD Result"

    public static let returnHomeTapped: String = "Back to home button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PlodTestResultViewController(interactor: interactor)
        }
    }
}

private class Interactor: PlodTestResultViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapReturnHome() {
        viewController?.showAlert(title: PlodTestResultScreenScenario.returnHomeTapped)
    }
}
