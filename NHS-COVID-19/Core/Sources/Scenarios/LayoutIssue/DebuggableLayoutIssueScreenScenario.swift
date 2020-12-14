//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import UIKit

public class DebuggableLayoutIssueScreenScenario: Scenario {
    public static var kind = ScenarioKind.prototype
    public static var name: String = "Debuggable layout issue"
    
    static var appController: AppController {
        let layoutIssueController = DebuggableLayoutIssueViewController()
        return BasicAppController(rootViewController: layoutIssueController)
    }
}
