//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class NegativeTestResultWithIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Negative Result (Isolation)"

    public static let nhsGuidanceTapped: String = "NHS guidance link tapped"
    public static let returnHomeTapped: String = "Back to home button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NegativeTestResultWithIsolationViewController(interactor: interactor, viewModel: .init(isolationEndDate: Date(timeIntervalSinceNow: 12 * 86400), testResultType: .firstResult), currentDateProvider: MockDateProvider())
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
            return NegativeTestResultWithIsolationViewController(interactor: interactor, viewModel: .init(isolationEndDate: Date(timeIntervalSinceNow: 12 * 86400), testResultType: .afterPositive), currentDateProvider: MockDateProvider())
        }
    }
}

private class Interactor: NegativeTestResultWithIsolationViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: NegativeTestResultAfterPositiveWithIsolationScreenScenario.onlineServicesLinkTapped)
    }

    func didTapReturnHome() {
        viewController?.showAlert(title: NegativeTestResultWithIsolationScreenScenario.returnHomeTapped)
    }

    func didTapNHSGuidanceLink() {
        viewController?.showAlert(title: NegativeTestResultWithIsolationScreenScenario.nhsGuidanceTapped)
    }
}
