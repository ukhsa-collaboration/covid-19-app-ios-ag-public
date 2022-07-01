//
// Copyright © 2021 NHSX. All rights reserved.
//

import Common
import Integration
import Interface
import UIKit

public class CheckInConfirmationFeedbackScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Confirmation Feedback"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            CheckInConfirmationFeedbackViewController()
        }
    }
}

