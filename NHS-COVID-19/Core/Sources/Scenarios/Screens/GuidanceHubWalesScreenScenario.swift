//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Integration
import Interface
import UIKit

public class GuidanceHubWalesScreenScenario: Scenario {

    public static let name = "COVID-19 Guidance Hub - Wales Only"
    public static let kind = ScenarioKind.screen
    public static let link1WalesTapped = "First link button tapped"
    public static let link2WalesTapped = "Second link button tapped"
    public static let link3WalesTapped = "Third link button tapped"
    public static let link4WalesTapped = "Fourth link button tapped"
    public static let link5WalesTapped = "Fifth link button tapped"
    public static let link6WalesTapped = "Sixth link button tapped"
    public static let link7WalesTapped = "Seventh link button tapped"
    public static let link8WalesTapped = "Eigth link button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            GuidanceHubWalesViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: GuidanceHubWalesViewController.Interacting {
    var newLabelForLongCovidWalesState: NewLabelState = NewLabelState(newLabelForName: "OpenedNewLongCovidInfoInWalesV4_35", setByCoordinator: true)

    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapWalesLink1() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link1WalesTapped)
    }

    func didTapWalesLink2() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link2WalesTapped)
    }

    func didTapWalesLink3() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link3WalesTapped)
    }

    func didTapWalesLink4() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link4WalesTapped)
    }

    func didTapWalesLink5() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link5WalesTapped)
    }

    func didTapWalesLink6() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link6WalesTapped)
    }

    func didTapWalesLink7() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link7WalesTapped)
    }

    func didTapWalesLink8() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link8WalesTapped)
    }

}
