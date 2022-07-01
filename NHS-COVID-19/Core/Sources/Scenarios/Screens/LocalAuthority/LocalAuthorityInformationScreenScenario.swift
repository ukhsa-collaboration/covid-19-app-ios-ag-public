//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LocalAuthorityInformationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Local Authority - Information"

    public static let continueTapped = "Continue tapped!"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            LocalAuthorityInformationViewController {
                parent.showAlert(title: continueTapped)
            }
        }
    }
}
