//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class IsolationPaymentInfoScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Isolation Payment"
    
    public static let applyTapped = "Apply tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return IsolationPaymentInfoViewController(interactor: interactor)
        }
    }
}

private class Interactor: IsolationPaymentInfoViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapApply() {
        viewController?.showAlert(title: IsolationPaymentInfoScreenScenario.applyTapped)
    }
}
