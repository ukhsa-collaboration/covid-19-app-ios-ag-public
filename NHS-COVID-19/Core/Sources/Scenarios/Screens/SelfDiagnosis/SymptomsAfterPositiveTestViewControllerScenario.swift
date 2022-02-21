//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class SymptomsAfterPositiveTestViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis after positive test"
    public static let returnHomeTapped: String = "Continue button tapped"
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return SymptomsAfterPositiveTestViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400), currentDateProvider: MockDateProvider())
        }
    }
}

private class Interactor: SymptomsAfterPositiveTestViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: SymptomsAfterPositiveTestViewControllerScenario.onlineServicesLinkTapped)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: SymptomsAfterPositiveTestViewControllerScenario.returnHomeTapped)
    }
    
}
