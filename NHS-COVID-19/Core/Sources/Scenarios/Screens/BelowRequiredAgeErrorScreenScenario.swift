//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BelowRequiredAgeErrorScreenScenario: Scenario {
    public static let name = "Onboarding - Below minimum age"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        BasicAppController(rootViewController: BelowRequiredAgeErrorViewController())
    }
}
