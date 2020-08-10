//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class NegativeTestResultScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Negative Result"
    
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let returnHomeTapped: String = "Back to home button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NegativeTestResultViewController(interactor: interactor)
        }
    }
}

private class Interactor: NegativeTestResultViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: NegativeTestResultScreenScenario.onlineServicesLinkTapped)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: NegativeTestResultScreenScenario.returnHomeTapped)
    }
}
