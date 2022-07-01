//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public class VoidTestResultNoIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Void, no Isolation"

    public static let onlineServicesLinkTapped: String = "Online services link tapped"
    public static let continueTapped: String = "Book a free test button tapped"
    public static let cancelTapped: String = "Cancel tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NonNegativeTestResultNoIsolationViewController(interactor: interactor, testResultType: .void)
        }
    }
}

private class Interactor: NonNegativeTestResultNoIsolationViewController.Interacting {
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: (() -> Void)?

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        didTapOnlineServicesLink = { [weak viewController] in
            viewController?.showAlert(title: VoidTestResultNoIsolationScreenScenario.onlineServicesLinkTapped)
        }

        didTapPrimaryButton = { [weak viewController] in
            viewController?.showAlert(title: VoidTestResultNoIsolationScreenScenario.continueTapped)
        }

        didTapCancel = { [weak viewController] in
            viewController?.showAlert(title: VoidTestResultNoIsolationScreenScenario.cancelTapped)
        }
    }
}
