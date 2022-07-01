//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public class PositiveTestResultNoIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Positive, no Isolation"

    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let continueTapped: String = "Continue button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NonNegativeTestResultNoIsolationViewController(interactor: interactor)
        }
    }
}

private class Interactor: NonNegativeTestResultNoIsolationViewController.Interacting {
    var didTapCancel: (() -> Void)? { nil }
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void

    init(viewController: UIViewController) {
        didTapOnlineServicesLink = { [weak viewController] in
            viewController?.showAlert(title: PositiveTestResultNoIsolationScreenScenario.onlineServicesLinkTapped)
        }

        didTapPrimaryButton = { [weak viewController] in
            viewController?.showAlert(title: PositiveTestResultNoIsolationScreenScenario.continueTapped)
        }
    }
}
