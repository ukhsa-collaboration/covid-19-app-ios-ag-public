//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseContinueIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case Continue Isolation"

    public static let numberOfDays = 14
    public static let cancelTapped = "Cancel button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseContinueIsolationViewController(interactor: interactor, secondTestAdviceDate: nil, isolationEndDate: Date(timeIntervalSinceNow: Double(Self.numberOfDays) * 86400), currentDateProvider: MockDateProvider())
        }
    }
}

private class Interactor: ContactCaseContinueIsolationViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseContinueIsolationScreenScenario.cancelTapped)
    }

    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseContinueIsolationScreenScenario.guidanceLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseContinueIsolationScreenScenario.backToHomeTapped)
    }
}
