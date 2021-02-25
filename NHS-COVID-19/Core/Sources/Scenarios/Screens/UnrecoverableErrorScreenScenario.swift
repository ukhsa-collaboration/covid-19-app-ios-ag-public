//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class UnrecoverableErrorScreenScenario: Scenario {
    public static let name = "Onboarding - Unfortunately you can’t run this app"
    public static let kind = ScenarioKind.screen
    public static let linkAlertTitle = "FAQ is tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return UnrecoverableErrorViewController(interactor: interactor)
        }
    }
}

private class Interactor: UnrecoverableErrorViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    func faqLinkTapped() {
        viewController?.showAlert(title: UnrecoverableErrorScreenScenario.linkAlertTitle)
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
