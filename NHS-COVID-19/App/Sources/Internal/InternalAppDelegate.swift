//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Logging
import Scenarios
import UIKit

@UIApplicationMain
class InternalAppDelegate: BaseAppDelegate {
    private let loggingManager = LoggingManager()
    private lazy var runner = Runner(loggingManager: loggingManager)
    
    override func makeAppController() -> AppController {
        runner.makeAppController()
    }
    
    override func makeLogHandler(label: String) -> LogHandler {
        loggingManager.makeLogHandler(label: label)
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        defer {
            runner.prepare(window!)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let result = runner.performAction(for: shortcutItem)
        completionHandler(result)
    }
}
