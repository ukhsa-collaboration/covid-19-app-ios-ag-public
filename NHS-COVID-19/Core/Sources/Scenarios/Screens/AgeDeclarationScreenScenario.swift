//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class AgeDeclarationScreenScenario: Scenario {
    
    public static let name = "Age Declaration"
    public static let kind = ScenarioKind.screen
    public static let backButtonAlertTitle = "Back button tapped"
    public static let yesOptionAlertTitle = "Yes option selected"
    public static let noOptionAlertTitle = "No option selected"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return AgeDeclarationViewController(interactor: interactor)
        }
    }
}

private class Interactor: AgeDeclarationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapBackButton() {
        viewController?.showAlert(title: AgeDeclarationScreenScenario.backButtonAlertTitle)
    }
    
    func didTapContinueButton(_ isOverAgeLimit: Bool) {
        if isOverAgeLimit {
            viewController?.showAlert(title: AgeDeclarationScreenScenario.yesOptionAlertTitle)
        } else {
            viewController?.showAlert(title: AgeDeclarationScreenScenario.noOptionAlertTitle)
        }
    }
}
