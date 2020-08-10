//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class InspectExperimentPrototypeScenario: Scenario {
    public static let name = "Inspect Experiment"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        InspectExperimentAppController()
    }
}
