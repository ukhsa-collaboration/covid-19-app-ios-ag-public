//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class NoSymptomsViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - No Symptoms"
    public static let returnHomeTapped: String = "Return home button tapped"
    public static let nhs111LinkTapped: String = "NHS 111 link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NoSymptomsViewController(interactor: interactor)
        }
    }
}

private class Interactor: NoSymptomsViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: NoSymptomsViewControllerScenario.returnHomeTapped)
    }
    
    func didTapNHS111Link() {
        viewController?.showAlert(title: NoSymptomsViewControllerScenario.nhs111LinkTapped)
    }
}
