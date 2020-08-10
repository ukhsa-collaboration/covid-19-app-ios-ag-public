//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public class PositiveTestResultScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Positive Result"
    
    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let continueTapped: String = "Continue button tapped"
    public static let noThanksLinkTapped: String = "No thanks link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PositiveTestResultViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400))
        }
    }
}

private class Interactor: PositiveTestResultViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: PositiveTestResultScreenScenario.onlineServicesLinkTapped)
    }
    
    func didTapContinue() {
        viewController?.showAlert(title: PositiveTestResultScreenScenario.continueTapped)
    }
}
