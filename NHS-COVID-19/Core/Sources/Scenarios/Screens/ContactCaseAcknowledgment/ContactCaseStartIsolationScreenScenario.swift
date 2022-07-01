//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseStartIsolationScreenEnglandScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case Start Isolation (England)"

    public static let numberOfDays = 10
    public static let exposureDate = Date(timeIntervalSinceNow: -86400)
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseStartIsolationEnglandViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: Double(Self.numberOfDays) * 86400), exposureDate: exposureDate, isolationPeriod: 11, currentDateProvider: MockDateProvider())
        }
    }
}

private class Interactor: ContactCaseStartIsolationEnglandViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenEnglandScenario.cancelTapped)
    }

    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenEnglandScenario.guidanceLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenEnglandScenario.backToHomeTapped)
    }

    func didTapGetTestButton() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenEnglandScenario.bookAFreeTestTapped)
    }
}

public class ContactCaseStartIsolationScreenWalesScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case Start Isolation (Wales)"

    public static let numberOfDays = 10
    public static let daysUntilSecondTest = 8
    public static let exposureDate = Date(timeIntervalSinceNow: -86400)
    public static let isolationEndDate = Date(timeIntervalSinceNow: Double(numberOfDays) * 86400)
    public static let secondTestAdviceDate = Date(timeIntervalSinceNow: Double(daysUntilSecondTest) * 86400)
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Take a COVID-19 test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = WalesInteractor(viewController: parent)
            return ContactCaseStartIsolationWalesViewController(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                exposureDate: exposureDate,
                secondTestAdviceDate: secondTestAdviceDate,
                isolationPeriod: 11,
                currentDateProvider: MockDateProvider()
            )
        }
    }
}

private class WalesInteractor: ContactCaseStartIsolationWalesViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenWalesScenario.cancelTapped)
    }

    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenWalesScenario.guidanceLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenWalesScenario.backToHomeTapped)
    }

    func didTapGetTestButton() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenWalesScenario.bookAFreeTestTapped)
    }
}
