//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class NoSymptomsIsolatingViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - No Symptoms (Isolating)"
    public static let returnHomeTapped: String = "Back to home button tapped"
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let cancelButtonTapped: String = "Cancel button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NoSymptomsIsolatingViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 14 * 86400))
        }
    }
}

private class Interactor: NoSymptomsIsolatingViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: NoSymptomsIsolatingViewControllerScenario.onlineServicesLinkTapped)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: NoSymptomsIsolatingViewControllerScenario.returnHomeTapped)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: NoSymptomsIsolatingViewControllerScenario.cancelButtonTapped)
    }
    
}
