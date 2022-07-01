//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class StartOnboardingScreenScenario: Scenario {
    public static let name = "Onboarding - Welcome (Check-In On)"
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
                },
                shouldShowVenueCheckIn: true
            )
        }
    }
}

public class StartOnboardingNoCheckInScreenScenario: Scenario {
    public static let name = "Onboarding - Welcome (No Check-In)"
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
                },
                shouldShowVenueCheckIn: false
            )
        }
    }
}
