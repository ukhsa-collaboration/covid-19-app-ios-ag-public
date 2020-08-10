//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class PermissionsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "On-boarding - Permissions"
    
    public static let continueConfirmationAlertTitle = "Continue tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            parent.isNavigationBarHidden = true
            return PermissionsViewController { [weak parent] in
                parent?.showAlert(title: Self.continueConfirmationAlertTitle)
            }
        }
    }
}
