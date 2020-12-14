//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import UIKit

public class PolicyUpdateLayoutIssueScreenScenario: Scenario {
    public static var kind = ScenarioKind.prototype
    public static var name: String = "Policy Update layout issue"
    
    static var appController: AppController {
        let layoutIssueController = LayoutIssueViewController()
        return BasicAppController(rootViewController: layoutIssueController)
    }
}
