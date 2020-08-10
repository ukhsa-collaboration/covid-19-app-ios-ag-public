//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ExposureNotificationScenario: Scenario {
    public static let name = "Exposure Notification (Debug UI)"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        ExposureNotificationAppController()
    }
}
