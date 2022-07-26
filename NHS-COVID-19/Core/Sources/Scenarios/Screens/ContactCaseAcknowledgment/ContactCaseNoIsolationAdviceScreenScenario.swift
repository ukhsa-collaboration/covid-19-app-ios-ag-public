//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationAdviceScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Advice"

    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkForContactsTapped = "Guidance for contacts link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = ContactCaseNoIsolationAdviceInteractor(viewController: parent)
            return ContactCaseNoIsolationAdviceViewController(interactor: interactor)
        }
    }
}

private class ContactCaseNoIsolationAdviceInteractor: ContactCaseNoIsolationAdviceViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationAdviceScreenScenario.backToHomeTapped)
    }

    func didTapReadGuidanceForContacts() {
        viewController?.showAlert(title: ContactCaseNoIsolationAdviceScreenScenario.guidanceLinkForContactsTapped)
    }
}
