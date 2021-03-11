//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class RiskyVenueInformationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Risky Venue - Warn Only"
    
    public static let venueName = "McDonald"
    public static let checkInDate = Calendar.current.date(from: DateComponents(year: 2020, month: 7, day: 10))!
    public static let goHomeTapped = "Go home tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return RiskyVenueInformationViewController(
                interactor: interactor,
                viewModel: .init(venueName: venueName, checkInDate: checkInDate)
            )
        }
    }
}

private class Interactor: RiskyVenueInformationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func goHomeTapped() {
        viewController?.showAlert(title: RiskyVenueInformationScreenScenario.goHomeTapped)
    }
    
}
