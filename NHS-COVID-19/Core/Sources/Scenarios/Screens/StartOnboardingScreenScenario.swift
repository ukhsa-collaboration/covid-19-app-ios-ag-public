//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class StartOnboardingScreenScenario: Scenario {
    public static let name = "Onboarding - Welcome"
    public static let kind = ScenarioKind.screen
    public static let continueConfirmationAlertTitle = "Age confirmation tapped"
    public static let rejectAlertTitle = "Age rejection tapped"
    public static let moreButtonConfirmationAlertTitle = "More tapped"
    
    static var appController: AppController {
        NavigationAppController { navigationController in
            StartOnboardingViewController(
                complete: {
                    navigationController.showAlert(title: Self.continueConfirmationAlertTitle)
                },
                reject: {
                    navigationController.showAlert(title: Self.rejectAlertTitle)
                }
            )
        }
    }
}
