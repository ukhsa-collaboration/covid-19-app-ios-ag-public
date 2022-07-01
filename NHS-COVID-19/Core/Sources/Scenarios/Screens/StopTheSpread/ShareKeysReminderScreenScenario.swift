//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ShareKeysReminderScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Share keys - Reminder"

    public static let doNotShareTapped = "Do not share tapped"
    public static let shareTapped = "Share result tapped"

    static var appController: AppController {
        NavigationAppController { parent in
            let interactor = Interactor(
                didTapShareResult: { parent.showAlert(title: shareTapped) },
                didTapDoNotShareResult: { parent.showAlert(title: doNotShareTapped) }
            )
            return ShareKeysReminderViewController(interactor: interactor)
        }
    }
}

private struct Interactor: ShareKeysReminderViewController.Interacting {
    let didTapShareResult: () -> Void
    let didTapDoNotShareResult: () -> Void
}
