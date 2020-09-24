//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class NegativeTestResultWithIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Negative Result (Isolation)"
    
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let returnHomeTapped: String = "Back to home button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 12 * 86400))
        }
    }
}

public class NegativeTestResultAfterPositiveWithIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Negative Result (After positive)"
    
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 12 * 86400), testResultType: .afterPositive)
        }
    }
}

private class Interactor: NegativeTestResultWithIsolationViewController.Interacting {
    
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
