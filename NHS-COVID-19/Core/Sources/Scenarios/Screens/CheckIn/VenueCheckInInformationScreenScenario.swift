//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class VenueCheckInInformationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Venue CheckIn Information"
    
    public static let didTapDismissAlertTitle = "Dismiss tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            parent.setNavigationBarHidden(true, animated: false)
            let interactor = Interactor(viewController: parent)
            return VenueCheckInInformationViewController(interactor: interactor)
        }
    }
}

private class Interactor: VenueCheckInInformationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapDismiss() {
        viewController?.showAlert(title: VenueCheckInInformationScreenScenario.didTapDismissAlertTitle)
    }
    
}
