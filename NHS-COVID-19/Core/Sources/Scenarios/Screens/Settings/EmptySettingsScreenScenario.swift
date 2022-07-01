//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class EmptySettingsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Empty settings"
    private static let description: String = "There are no records yet."

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let viewController = UIViewController()
            viewController.view = EmptySettingsView(image: UIImage(.settingInfo), description: description)
            return viewController
        }
    }
}
