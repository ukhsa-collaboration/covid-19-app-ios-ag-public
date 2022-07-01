//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class RiskyVenueInformationBookATestScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Risky Venue - Warn and book a test"
    public static let bookATestTapped = "Book a test tapped!"
    public static let bookATestLaterTapped = "I'll do it later tapped!"
    public static let closeTapped = "Close tapped!"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return RiskyVenueInformationBookATestViewController(interactor: interactor)
        }
    }
}

private class Interactor: RiskyVenueInformationBookATestViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func bookATestTapped() {
        viewController?.showAlert(title: RiskyVenueInformationBookATestScreenScenario.bookATestTapped)
    }

    func bookATestLaterTapped() {
        viewController?.showAlert(title: RiskyVenueInformationBookATestScreenScenario.bookATestLaterTapped)
    }

    func closeTapped() {
        viewController?.showAlert(title: RiskyVenueInformationBookATestScreenScenario.closeTapped)
    }
}
