//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseExposureInfoScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "EN Exposure Info (actions depend on your vaccination status)"
    
    public static let continueTapped = "'Continue' button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseExposureInfoViewController(interactor: interactor)
        }
    }
}

private class Interactor: ContactCaseExposureInfoViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapContinue() {
        viewController?.showAlert(title: ContactCaseExposureInfoScenario.continueTapped)
    }
    
}
