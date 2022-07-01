//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class MyAreaScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Settings - My Area"

    public static var postcode: String = "BH21"
    public static var localAuthority: String = "Bournemouth, Christchurch and Poolerr"

    public static let editTappeed = "Edit tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return MyAreaTableViewController(
                viewModel: MyAreaTableViewController.ViewModel(postcode: .constant(postcode), localAuthority: .constant(localAuthority)),
                interactor: interactor
            )
        }
    }
}

private class Interactor: MyAreaTableViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapEditPostcode() {
        viewController?.showAlert(title: MyAreaScreenScenario.editTappeed)
    }

}
