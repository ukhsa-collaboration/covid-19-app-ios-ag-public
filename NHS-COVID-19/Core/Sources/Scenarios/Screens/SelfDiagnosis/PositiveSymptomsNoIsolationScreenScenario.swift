//
// Copyright © 2022 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class PositiveSymptomsNoIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - Positive symptoms No isolation"

    public static let cancelTapped: String = "Cancel tapped"
    public static let nhs111OnlineLinkTapped = "NHS 111 Online link tapped"
    public static let backHomeButtonTapped: String = "Back to home screen button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PositiveSymptomsNoIsolationViewController(interactor: interactor)
        }
    }
}

private class Interactor: PositiveSymptomsNoIsolationViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: PositiveSymptomsNoIsolationScreenScenario.cancelTapped)
    }

    func nhs111OnlineLinkTapped() {
        viewController?.showAlert(title: PositiveSymptomsNoIsolationScreenScenario.nhs111OnlineLinkTapped)
    }

    func backHomeButtonTapped() {
        viewController?.showAlert(title: PositiveSymptomsNoIsolationScreenScenario.backHomeButtonTapped)
    }
}
