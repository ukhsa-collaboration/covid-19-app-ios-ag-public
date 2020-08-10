//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class UnrecoverableErrorScreenScenario: Scenario {
    public static let name = "On-boarding - Unfortunately you can’t run this app"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        let home = UnrecoverableErrorViewController()
        return BasicAppController(rootViewController: home)
    }
}
