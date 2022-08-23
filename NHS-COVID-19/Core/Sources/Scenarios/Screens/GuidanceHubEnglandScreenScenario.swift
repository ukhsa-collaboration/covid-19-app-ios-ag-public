//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Integration
import Interface
import UIKit

public class GuidanceHubEnglandScreenScenario: Scenario {

    public static let name = "COVID-19 Guidance Hub - England Only"
    public static let kind = ScenarioKind.screen
    public static let link1EnglandTapped = "First link button tapped"
    public static let link2EnglandTapped = "Second link button tapped"
    public static let link3EnglandTapped = "Third link button tapped"
    public static let link4EnglandTapped = "Fourth link button tapped"
    public static let link5EnglandTapped = "Fitfh link button tapped"
    public static let link6EnglandTapped = "Sixth link button tapped"
    public static let link7EnglandTapped = "Seventh link button tapped"
    public static let link8EnglandTapped = "Eighth link button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            GuidanceHubEnglandViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: GuidanceHubEnglandViewController.Interacting {
    var newLabelForLongCovidEnglandState: NewLabelState = NewLabelState(newLabelForName: "OpenedNewLongCovidInfoInEnglandV4_35", setByCoordinator: true)

    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapEnglandLink1() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link1EnglandTapped)
    }

    func didTapEnlgandLink2() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link2EnglandTapped)
    }

    func didTapEnglandLink3() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link3EnglandTapped)
    }

    func didTapEnglandLink4() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link4EnglandTapped)
    }

    func didTapEnglandLink5() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link5EnglandTapped)
    }

    func didTapEnglandLink6() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link6EnglandTapped)
    }

    func didTapEnglandLink7() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link7EnglandTapped)
    }

    func didTapEnglandLink8() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.link8EnglandTapped)
    }
}
