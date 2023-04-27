//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class ClosureScreenScenario: Scenario {
    public static let name = "Closure screen - About the app closing down"
    public static let kind = ScenarioKind.screen
    public static let link1Tapped = "First link button tapped"
    public static let link2Tapped = "Second link button tapped"
    public static let link3Tapped = "Third link button tapped"
    public static let link4Tapped = "Fourth link button tapped"
    public static let link5Tapped = "Fifth link button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ClosureViewController(interactor: interactor)
        }
    }
}

private class Interactor: ClosureViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapURL1() {
        viewController?.showAlert(title: ClosureScreenScenario.link1Tapped)
    }

    func didTapURL2() {
        viewController?.showAlert(title: ClosureScreenScenario.link2Tapped)
    }

    func didTapURL3() {
        viewController?.showAlert(title: ClosureScreenScenario.link3Tapped)
    }

    func didTapURL4() {
        viewController?.showAlert(title: ClosureScreenScenario.link4Tapped)
    }

    func didTapURL5() {
        viewController?.showAlert(title: ClosureScreenScenario.link5Tapped)
    }
}
