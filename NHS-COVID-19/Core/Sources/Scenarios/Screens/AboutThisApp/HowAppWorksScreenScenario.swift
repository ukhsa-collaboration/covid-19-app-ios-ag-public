//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class HowAppWorksScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "How the app works"
    
    public static let continueButtonTapped = "Continue Button Tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return HowAppWorksViewController(interactor: interactor)
        }
    }
}

private class Interactor: HowAppWorksViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapContinueButton() {
        viewController?.showAlert(title: HowAppWorksScreenScenario.continueButtonTapped)
    }
    
}
