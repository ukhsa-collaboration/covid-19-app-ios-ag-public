//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BluetoothDisabledScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Onboarding - Bluetooth not enabled"
    
    public static let enableTapped = "Go to settings tapped!"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            BluetoothDisabledViewController(country: .england)
        }
    }
}
