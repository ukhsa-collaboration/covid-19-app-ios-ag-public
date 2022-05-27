//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class HowDoYouFeelScreenScenario: Scenario {
    
    public static let name = "How you feel"
    public static let kind = ScenarioKind.screen
    public static let backButtonAlertTitle = "Back button tapped"
    public static let yesOptionAlertTitle = "Yes option selected"
    public static let noOptionAlertTitle = "No option selected"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return HowDoYouFeelViewController(
                interactor: interactor,
                doYouFeelWell: nil
            )
        }
    }
}

private class Interactor: HowDoYouFeelViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapBackButton() {
        viewController?.showAlert(title: HowDoYouFeelScreenScenario.backButtonAlertTitle)
    }
    
    func didTapContinueButton(_ doYouFeelWell: Bool) {
        if doYouFeelWell {
            viewController?.showAlert(title: HowDoYouFeelScreenScenario.yesOptionAlertTitle)
        } else {
            viewController?.showAlert(title: HowDoYouFeelScreenScenario.noOptionAlertTitle)
        }
    }
}
