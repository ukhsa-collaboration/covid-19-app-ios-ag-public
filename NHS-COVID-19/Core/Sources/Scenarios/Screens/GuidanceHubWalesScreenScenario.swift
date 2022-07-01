//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Integration
import Interface
import UIKit

public class GuidanceHubWalesScreenScenario: Scenario {

    public static let name = "COVID-19 Guidance Hub - Wales Only"
    public static let kind = ScenarioKind.screen
    public static let link1Tapped = "First link button tapped"
    public static let link2Tapped = "Second link button tapped"
    public static let link3Tapped = "Third link button tapped"
    public static let link4Tapped = "Fourth link button tapped"
    public static let link5Tapped = "Fifth link button tapped"
    public static let link6Tapped = "Sixth link button tapped"
    public static let link7Tapped = "Seventh link button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            GuidanceHubWalesViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: GuidanceHubWalesViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapLink1() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link1Tapped)
    }

    func didTapLink2() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link2Tapped)
    }

    func didTapLink3() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link3Tapped)
    }

    func didTapLink4() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link4Tapped)
    }

    func didTapLink5() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link5Tapped)
    }

    func didTapLink6() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link6Tapped)
    }

    func didTapLink7() {
        viewController.showAlert(title: GuidanceHubWalesScreenScenario.link7Tapped)
    }

}
