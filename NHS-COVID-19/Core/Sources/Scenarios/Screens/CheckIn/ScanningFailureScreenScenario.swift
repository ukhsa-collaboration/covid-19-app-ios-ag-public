//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ScanningFailureScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Scanning Failure"
    
    public static let goHomeTapped = "Go home tapped!"
    public static let showHelpTapped = "Show help tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ScanningFailureViewController(interactor: interactor)
        }
    }
}

private class Interactor: ScanningFailureViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func goHome() {
        viewController?.showAlert(title: ScanningFailureScreenScenario.goHomeTapped)
    }
    
    func showHelp() {
        viewController?.showAlert(title: ScanningFailureScreenScenario.showHelpTapped)
    }
}
