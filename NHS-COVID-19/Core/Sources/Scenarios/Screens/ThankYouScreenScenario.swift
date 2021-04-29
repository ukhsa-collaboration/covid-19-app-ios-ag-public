//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class ThankYouScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Thank You - Share key completion"
    
    public static let backToHomeTapped: String = "Back to home tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ThankYouViewController.viewController(
                for: .completed,
                interactor: interactor
            )
        }
    }
}

private class Interactor: ThankYouViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func action() {
        viewController?.showAlert(title: ThankYouScreenScenario.backToHomeTapped)
    }
}
