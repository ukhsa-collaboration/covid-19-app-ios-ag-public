//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ShareKeysScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Stop the Spread - Share Keys (New)"
    
    public static let notifyAnonymouslyTapped = "'Continue' tapped"
    
    static var appController: AppController {
        NavigationAppController { parent in
            let interactor = Interactor(
                didTapContinue: { parent.showAlert(title: notifyAnonymouslyTapped) }
            )
            return ShareKeysViewController(interactor: interactor)
            
        }
    }
}

private struct Interactor: ShareKeysViewController.Interacting {
    var didTapContinue: () -> Void
}
