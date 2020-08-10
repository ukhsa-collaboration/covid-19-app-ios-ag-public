//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Logging
import UIKit

@UIApplicationMain
class ProductionAppDelegate: BaseAppDelegate {
    override func makeAppController() -> AppController {
        CoordinatedAppController()
    }
    
    override func makeLogHandler(label: String) -> LogHandler {
        NoOpLogHandler()
    }
}
