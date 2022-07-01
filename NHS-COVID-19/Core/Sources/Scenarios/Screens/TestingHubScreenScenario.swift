//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

enum TestingHubUserCase {
    case notIsolating
    case isolating
}

protocol CommonTestingHubScreenScenario: Scenario {
    static var userCase: TestingHubUserCase { get }
}

extension CommonTestingHubScreenScenario {

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return TestingHubViewController(
                interactor: interactor,
                showOrderTestButton: .constant(userCase == .isolating),
                showFindOutAboutTestingButton: .constant(userCase == .notIsolating)
            )
        }
    }

}

public enum TestingHubScreenAlertTitle {

    public static let bookFreeTest = "Book a free test tapped"
    public static let orderAFreeTestingKit = "Order a free testing kit tapped"
    public static let enterTestResult = "Enter a test result tapped"
    public static let findOutAboutTestingFromAccordion = "Find out about testing tapped"

}

public class TestingHubScreenNotIsolatingScenario: CommonTestingHubScreenScenario {

    public static let name = "Testing Hub - User is not isolated"
    public static let kind = ScenarioKind.screen
    static let userCase = TestingHubUserCase.notIsolating

}

public class TestingHubScreenIsolatingScenario: CommonTestingHubScreenScenario {

    public static let name = "Testing Hub - User is isolated"
    public static let kind = ScenarioKind.screen
    static let userCase = TestingHubUserCase.isolating

}

private class Interactor: TestingHubViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapBookFreeTestButton() {
        viewController?.showAlert(title: TestingHubScreenAlertTitle.bookFreeTest)
    }

    func didTapOrderAFreeTestingKit() {
        viewController?.showAlert(title: TestingHubScreenAlertTitle.orderAFreeTestingKit)
    }

    func didTapEnterTestResultButton() {
        viewController?.showAlert(title: TestingHubScreenAlertTitle.enterTestResult)
    }

    func didTapFindOutAboutTestingLink() {
        viewController?.showAlert(title: TestingHubScreenAlertTitle.findOutAboutTestingFromAccordion)
    }
}
