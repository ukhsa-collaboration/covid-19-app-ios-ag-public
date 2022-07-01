//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class PrivacyScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Onboarding - Privacy and data"

    public static let privacyNoticeTapped = "Privacy Notice tapped"
    public static let termsOfUseTapped = "Terms of use tapped"
    public static let agreeButtonTapped = "I agree tapped"
    public static let noThanksButtonTapped = "No thanks tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PrivacyViewController(interactor: interactor)
        }
    }
}

private class Interactor: PrivacyViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrivacyNotice() {
        viewController?.showAlert(title: PrivacyScreenScenario.privacyNoticeTapped)
    }

    func didTapTermsOfUse() {
        viewController?.showAlert(title: PrivacyScreenScenario.termsOfUseTapped)
    }

    func didTapAgree() {
        viewController?.showAlert(title: PrivacyScreenScenario.agreeButtonTapped)
    }

    func didTapNoThanks() {
        viewController?.showAlert(title: PrivacyScreenScenario.noThanksButtonTapped)
    }
}
