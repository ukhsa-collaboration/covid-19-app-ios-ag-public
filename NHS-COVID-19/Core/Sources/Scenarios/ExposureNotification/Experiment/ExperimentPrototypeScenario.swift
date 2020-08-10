//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ExperimentPrototypeScenario: Scenario {
    public static let name = "Exposure Experiment"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        ExperimentAppController()
    }
}
