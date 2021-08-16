//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class GetAFreeTestKitScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Get a free test kit"
    
    public static let bookATestTapped: String = "Get a free test kit button tapped"
    public static let cancelTapped: String = "I already have a test kit button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return GetAFreeTestKitViewController(interactor: interactor)
        }
    }
}

private class Interactor: GetAFreeTestKitViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapAlreadyHaveATest() {
        viewController?.showAlert(title: GetAFreeTestKitScreenScenario.cancelTapped)
    }
    
    func didTapBookATest() {
        viewController?.showAlert(title: GetAFreeTestKitScreenScenario.bookATestTapped)
    }
}
