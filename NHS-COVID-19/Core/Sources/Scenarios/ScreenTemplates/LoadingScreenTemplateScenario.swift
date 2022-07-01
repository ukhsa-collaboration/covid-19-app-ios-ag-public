//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LoadingScreenTemplateScenario: Scenario {
    public static var kind = ScenarioKind.screenTemplate
    public static var name: String = "Loading screen"

    public static let cancelTapped: String = "Cancel button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return LoadingViewController(interactor: interactor, title: "Loading title")
        }
    }
}

private class Interactor: LoadingViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: LoadingScreenTemplateScenario.cancelTapped)
    }
}
