//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class UnknownTestResultsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Unknown Result"

    public static let openStoreTapped: String = "Open store button tapped"
    public static let closeTapped: String = "Close button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return UnknownTestResultsViewController(interactor: interactor)
        }
    }
}

private class Interactor: UnknownTestResultsViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapOpenStore() {
        viewController?.showAlert(title: UnknownTestResultsScreenScenario.openStoreTapped)
    }

    func didTapClose() {
        viewController?.showAlert(title: UnknownTestResultsScreenScenario.closeTapped)
    }
}
