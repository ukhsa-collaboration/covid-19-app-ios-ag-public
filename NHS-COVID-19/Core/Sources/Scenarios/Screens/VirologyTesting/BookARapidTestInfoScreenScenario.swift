//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class BookARapidTestInfoScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Book A Rapid Test Info"

    public static let bookATestTapped: String = "Book a test now tapped"
    public static let cancelTapped: String = "Cancel tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return BookARapidTestInfoViewController(interactor: interactor)
        }
    }
}

private class Interactor: BookARapidTestInfoViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapBookATest() {
        viewController?.showAlert(title: BookARapidTestInfoScreenScenario.bookATestTapped)
    }

    func didTapAlreadyHaveATest() {
        viewController?.showAlert(title: BookARapidTestInfoScreenScenario.cancelTapped)
    }
}
