//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import UIKit

public protocol AppController {
    var rootViewController: UIViewController { get }
    
    func performBackgroundTask(task: BackgroundTask)
    
    func handleUserNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void)
}

extension AppController {
    public func performBackgroundTask(task: BackgroundTask) {
        task.setTaskCompleted(success: true)
    }
    
    public func handleUserNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
