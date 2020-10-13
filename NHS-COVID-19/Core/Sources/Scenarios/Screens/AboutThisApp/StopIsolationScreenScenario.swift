//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class StopIsolationScreenScenario: Scenario {
    public static let name = "Stop Isolation"
    public static let kind = ScenarioKind.screen
    
    public static let stopIsolationTapped = "Tapped stop isolation button"
    
    static var appController: AppController {
        NavigationAppController { parent in
            let interactor = Interactor(
                stopIsolation: { [weak parent] in
                    parent?.showAlert(title: stopIsolationTapped)
                }
            )
            
            return StopIsolationViewController(interactor: interactor)
        }
    }
}

private struct Interactor: StopIsolationViewController.Interacting {
    var stopIsolation: () -> Void
}
