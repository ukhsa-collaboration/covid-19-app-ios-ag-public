//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class DailyContactTestingConfirmationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Daily Contact Testing - Confirmation"
    
    public static let confirmButtonTapped = "Confirm button tapped"
    public static let backButtonTapped = "Back button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return DailyContactTestingConfirmationViewController(interactor: interactor)
        }
    }
}

private class Interactor: DailyContactTestingConfirmationViewController.Interacting {
    func didTapConfirm() {
        viewController?.showAlert(title: DailyContactTestingConfirmationScreenScenario.confirmButtonTapped)
    }
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
}
