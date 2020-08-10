//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class CameraFailureScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Camera Failure"
    
    public static let goHomeTapped = "Go home tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return CameraFailureViewController(interactor: interactor)
        }
    }
}

private class Interactor: CameraFailureViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func goHome() {
        viewController?.showAlert(title: CameraFailureScreenScenario.goHomeTapped)
    }
    
}
