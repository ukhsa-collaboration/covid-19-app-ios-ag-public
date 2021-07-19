//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class ContactTracingAdviceScreenShouldNotPauseScenario: Scenario {
    public static let name = "Contact Tracing Advice - Should Not Pause CT"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            ContactTracingAdviceViewController()
        }
    }
}
