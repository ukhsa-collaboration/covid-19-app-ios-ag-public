//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public protocol SelfReportingNegativeOrVoidTestResultScreenScenario {
    static var country: Country { get }
}

extension SelfReportingNegativeOrVoidTestResultScreenScenario {
    public static var kind: ScenarioKind { .screen }
    public static var findOutMoreLink: String { "Find out what to do next when result is negative or void tapped" }
    public static var nhs111OnlineLink: String { "NHS 111 Online link tapped" }
    public static var primaryButtonTapped: String { "Back to home button tapped" }
    public static var backButtonTapped: String { "Back button tapped" }

    static var appController: AppController {
        return NavigationAppController { (parent: UINavigationController) in
            SelfReportingNegativeOrVoidTestResultViewController(
                interactor: Interactor(viewController: parent),
                country: country
            )
        }
    }
}

public class SelfReportingNegativeOrVoidTestResultEnglandScreenScenario: SelfReportingNegativeOrVoidTestResultScreenScenario, Scenario {
    public static let country = Country.england
    public static let name = "Self-Reporting - Negative or Void Test Result (England)"
}

public class SelfReportingNegativeOrVoidTestResultWalesScreenScenario: SelfReportingNegativeOrVoidTestResultScreenScenario, Scenario {
    public static let country = Country.wales
    public static let name = "Self-Reporting - Negative or Void Test Result (Wales)"

}

private struct Interactor: SelfReportingNegativeOrVoidTestResultViewController.Interacting {

    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapFindOutMoreLink() {
        viewController.showAlert(title: SelfReportingNegativeOrVoidTestResultEnglandScreenScenario.findOutMoreLink)
    }

    func didTapNHS111Online() {
        viewController.showAlert(title: SelfReportingNegativeOrVoidTestResultEnglandScreenScenario.nhs111OnlineLink)
    }

    func didTapPrimaryButton() {
        viewController.showAlert(title: SelfReportingNegativeOrVoidTestResultEnglandScreenScenario.primaryButtonTapped)
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingNegativeOrVoidTestResultEnglandScreenScenario.backButtonTapped)
    }
}
